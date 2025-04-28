import SwiftUI
import RealmSwift

struct InvestimentoDetailView: View {
    var investmentId: String
    @StateObject private var store = InvestmentDetailStore()
    @State private var selectedTab: Tab = .transacoes
    @State private var selectedPeriod: Period = .oneMonth
    @State private var showingAdjustSheet = false
    @State private var showingResgateAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    enum Tab {
        case grafico
        case transacoes
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let errorMessage = store.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    headerSection
                    navigationSection
                    contentSection
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingResgateAlert = true
                }) {
                    Image(systemName: "arrow.down.left.circle")
                        .accessibilityLabel("Resgatar investimento")
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAdjustSheet) {
            AjusteSaldoInvestimentoSheet(store: store)
        }
        .alert("Resgate", isPresented: $showingResgateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Funcionalidade de resgate em breve!")
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAdjustSheet = true
                    }) {
                        Label("Ajustar Saldo", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    .accessibilityLabel("Ajustar saldo do investimento")
                    .padding()
                }
            }
        )
        .onAppear {
            debugPrint("[DEBUG] View appeared for investment ID: \(investmentId)")
            Task { await fetchData() }
        }
        .refreshable {
            await store.fetchInvestmentDetailFromAPI(id: investmentId)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .alert("Erro", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func fetchData() async {
        debugPrint("[DEBUG] fetchData started for id: \(investmentId)")
        isLoading = true
        errorMessage = nil
        do {
            await store.fetchInvestmentDetail(by: investmentId)
            debugPrint("[DEBUG] fetchData completed. Investment detail: \(String(describing: store.investmentDetail))")
            if let transactions = store.investmentDetail?.transactions {
                debugPrint("[DEBUG] Transactions count: \(transactions.count)")
            }
        } catch {
            debugPrint("[DEBUG] Error fetching data: \(error)")
            errorMessage = "Não foi possível carregar os dados do investimento. Tente novamente."
        }
        isLoading = false
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "building.2.crop.circle")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                    .accessibilityHidden(true)

                Spacer()

                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.blue)
                    .accessibilityHidden(true)
            }

            VStack(spacing: 4) {
                Text(store.investmentDetail?.name ?? "-")
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(store.investmentDetail?.currentBalance ?? 0.0, format: .currency(code: "BRL"))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .accessibilityLabel("Saldo atual: \(formatCurrency(store.investmentDetail?.currentBalance ?? 0.0))")
            }
            .padding(.top, 4)

            Divider()

            HStack {
                infoColumn(title: "Liquidez", value: store.investmentDetail?.liquidity ?? "-")
                Spacer()
                infoColumn(title: "Rentabilidade", value: formatPercentage(store.investmentDetail?.annualProfitability ?? 0))
                Spacer()
                infoColumn(title: "Vencimento", value: formattedDate(store.investmentDetail?.maturityDate))
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }

    private func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value / 100)) ?? "0,00%"
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }

    private var navigationSection: some View {
        HStack(spacing: 0) {
            Button {
                selectedTab = .transacoes
            } label: {
                Text("Transações")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(selectedTab == .transacoes ? .blue : .gray)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == .transacoes ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(20)
            }
            .accessibilityLabel("Visualizar transações")
            .accessibilityAddTraits(selectedTab == .transacoes ? .isSelected : [])

            Button {
                selectedTab = .grafico
            } label: {
                Text("Gráfico")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(selectedTab == .grafico ? .blue : .gray)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selectedTab == .grafico ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(20)
            }
            .accessibilityLabel("Visualizar gráfico")
            .accessibilityAddTraits(selectedTab == .grafico ? .isSelected : [])
        }
        .background(Color(.systemGray5))
        .clipShape(Capsule())
        .padding(.top)
    }

    private var contentSection: some View {
        Group {
            switch selectedTab {
            case .grafico:
                graficoSection
            case .transacoes:
                transacoesSection
            }
        }
        .padding(.top)
        .onAppear {
            debugPrint("[DEBUG] Content section appeared with tab: \(selectedTab)")
        }
    }

    private var graficoSection: some View {
        VStack(spacing: 16) {
            InvestmentChartSelectorView(selectedPeriod: $selectedPeriod)
            if let chartData = store.investmentDetail?.chartData {
                let dados = Array(chartData.map { InvestmentDataPoint(date: $0.date, value: $0.value) })
                InvestmentChartView(dados: dados)
            } else {
                emptyStateView(message: "Não há dados de gráfico disponíveis")
            }
        }
    }

    private var transacoesSection: some View {
        VStack(spacing: 0) {
            if let transactions = store.investmentDetail?.transactions {
                let sortedTransactions = Array(transactions.sorted(by: { $0.date > $1.date }))
                
                if sortedTransactions.isEmpty {
                    emptyStateView(message: "Não há transações disponíveis")
                        .padding(.top, 20)
                } else {
                    ForEach(sortedTransactions) { transacao in
                        TransactionRow(transaction: transacao, onDelete: { transaction in
                            deleteTransaction(transaction)
                        })
                        
                        if transacao.id != sortedTransactions.last?.id {
                            Divider()
                                .padding(.horizontal, 16)
                        }
                    }
                }
            } else {
                emptyStateView(message: "Não há transações disponíveis")
                    .padding(.top, 20)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func deleteTransaction(_ transaction: InvestmentTransaction) {
        guard let investimento = store.investmentDetail else { return }
        
        do {
            let realm = try Realm()
            if let thawedInvestimento = investimento.thaw(),
               let transactionToDelete = thawedInvestimento.transactions.first(where: { $0.id == transaction.id }) {
                try realm.write {
                    // Ajusta o saldo atual removendo o valor da transação
                    thawedInvestimento.currentBalance -= transaction.value
                    // Remove a transação
                    realm.delete(transactionToDelete)
                }
                Task {
                    await store.fetchInvestmentDetail(by: investimento.id)
                }
            }
        } catch {
            errorMessage = "Erro ao excluir transação."
        }
    }

    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func infoColumn(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.footnote)
                .fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct TransactionRow: View {
    let transaction: InvestmentTransaction
    let onDelete: (InvestmentTransaction) -> Void
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Linha superior com data
            Text(formattedDate(transaction.date))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            // Linha inferior com descrição e valor
            HStack {
                Text(transaction.descriptionText)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(formatCurrency(transaction.value))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(transaction.value >= 0 ? Color.green : Color.red)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Excluir", systemImage: "trash")
            }
        }
        .alert("Confirmar Exclusão", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                onDelete(transaction)
            }
        } message: {
            Text("Deseja realmente excluir esta transação? Esta ação não pode ser desfeita.")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let isNegative = value < 0
        let absoluteValue = abs(value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        let formattedValue = formatter.string(from: NSNumber(value: absoluteValue)) ?? "R$ 0,00"
        return (isNegative ? "- " : "+ ") + formattedValue
    }
}
