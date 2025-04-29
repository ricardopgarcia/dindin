import SwiftUI
import RealmSwift

extension String {
    func removingAccents() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
}

func investmentId(for account: Account) -> String {
    let cleanName = account.name
        .removingAccents()
        .lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")).inverted)
        .joined()
    return cleanName
}

struct SaldoView: View {
    @ObservedObject var store: AccountStore
    @State private var showToast = false
    @State private var showingForm = false
    @State private var editingAccount: Account? = nil
    @State private var isLoading = false
    @State private var expandedCategories: [String: Bool] = [:]

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        saldoTotalView
                            .padding(.horizontal)
                            .padding(.top, 8)

                        Divider()

                        ForEach(groupedByType.keys.sorted(), id: \.self) { type in
                            tipoSection(for: type)
                        }

                        Spacer(minLength: 120)
                    }
                    .padding(.top)
                    .background(Color(.systemBackground))
                }
                addButton
                if isLoading { loadingOverlay }
            }
            .refreshable {
                Task.detached {
                    await refreshData()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Saldo")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleExpandCollapse) {
                        Image(systemName: expandedCategories.values.contains(false) ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                AddEditAccountView(accountStore: store, accountToEdit: editingAccount)
            }
            .overlay(toastOverlay)
            .onAppear {
                initializeExpandState()
                store.startMonitoringNetwork()
            }
        }
    }

    private func tipoSection(for type: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleForType(type))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(groupedByType[type]?.keys.sorted() ?? [], id: \.self) { category in
                    categoriaSection(for: type, category: category)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }

    private func categoriaSection(for type: String, category: String) -> some View {
        DisclosureGroup(
            isExpanded: Binding(
                get: { expandedCategories[category] ?? true },
                set: { expandedCategories[category] = $0 }
            ),
            content: {
                VStack(spacing: 8) {
                    ForEach(groupedByType[type]?[category] ?? []) { account in
                        accountRow(account: account)
                    }
                }
                .padding(.top, 4)
            },
            label: {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text(category)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var saldoTotalView: some View {
        let total = store.accounts.map { $0.balance }.reduce(0, +)

        let safeTotal: Double = {
            if total.isNaN || total.isInfinite {
                return 0
            }
            return total
        }()

        return HStack {
            Text("R$ \(safeTotal, specifier: "%.2f")")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }

    private func accountRow(account: Account) -> some View {
        NavigationLink(destination: destinationView(for: account)) {
            HStack {
                if !account.icon.isEmpty {
                    Image(systemName: account.icon)
                        .frame(width: 24)
                        .foregroundColor(colorForCategory(account.category))
                }
                Text(account.name)
                Spacer()
                Text("R$ \(account.balance, specifier: "%.2f")")
                    .fontWeight(.medium)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    private var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    editingAccount = nil
                    showingForm = true
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .padding()
                }
            }
        }
    }

    private var loadingOverlay: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay(
                ProgressView("Carregando...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
            )
    }

    @ViewBuilder
    private func destinationView(for account: Account) -> some View {
        switch account.type {
        case "conta":
            ContaDetailView(account: account)
        case "cartao":
            CartaoDetailView(account: account)
        case "investimento":
            InvestimentoDetailView(investmentId: account.id)
        default:
            VStack {
                Text("Tipo de conta não suportado.")
                    .padding()
            }
        }
    }

    private func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Contas": return .blue
        case "Cartões": return .orange
        case "Ações": return .green
        case "FIIs": return .purple
        case "Criptomoedas": return .teal
        case "Espécie": return .gray
        case "CDBs": return .mint
        case "LCIs", "LCAs": return .indigo
        case "Fundos de Renda Fixa": return .cyan
        case "Fundos de Renda Variável": return .pink
        default: return .black
        }
    }

    private func refreshData() async {
        print("🔄 Iniciando Pull-to-Refresh de contas...")
        await MainActor.run {
            isLoading = true
        }

        await store.fetchAccountsFromAPI()

        await MainActor.run {
            isLoading = false
            showToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }

    private var toastOverlay: some View {
        VStack {
            Spacer()
            if showToast {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Sincronizado com sucesso")
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding(.bottom, 30)
                .transition(.move(edge: .bottom))
                .animation(.easeOut(duration: 0.3), value: showToast)
            }
        }
    }

    private var groupedByType: [String: [String: [Account]]] {
        Dictionary(grouping: store.accounts) { $0.type }.mapValues { accounts in
            Dictionary(grouping: accounts) { $0.category }
        }
    }

    private func titleForType(_ type: String) -> String {
        switch type {
        case "conta": return "Contas Bancárias"
        case "investimento": return "Investimentos"
        case "cartao": return "Cartões de Crédito"
        default: return type.capitalized
        }
    }

    private func initializeExpandState() {
        for type in groupedByType.keys {
            if let categories = groupedByType[type]?.keys {
                for category in categories {
                    expandedCategories[category] = true
                }
            }
        }
    }

    private func toggleExpandCollapse() {
        let shouldExpand = expandedCategories.values.contains(false)
        for type in groupedByType.keys {
            if let categories = groupedByType[type]?.keys {
                for category in categories {
                    expandedCategories[category] = shouldExpand
                }
            }
        }
    }
}
