
import SwiftUI
import RealmSwift

enum FiltroLancamentos: String, CaseIterable, Identifiable {
    case mesAtual = "Mês Atual"
    case mesAnterior = "Mês Anterior"
    case ultimos6Meses = "Últimos 6 Meses"
    case esteAno = "Este Ano"

    var id: String { self.rawValue }
}

struct ContaDetailView: View {
    var account: Account
    @ObservedResults(LancamentoItem.self) var allLancamentos

    @State private var lancamentos: [LancamentoItem] = []
    @State private var filtroSelecionado: FiltroLancamentos = .mesAtual
    @State private var isLoading = false
    @State private var currentTask: Task<Void, Never>? = nil
    
    var body: some View {
        let grupos = lancamentosAgrupadosPorDia()
        let saldosAcumulados = calcularSaldosAcumuladosPorDia(grupos)
        NavigationView {
            ZStack {
                VStack {
                    Picker("Filtro", selection: $filtroSelecionado) {
                        ForEach(FiltroLancamentos.allCases) { filtro in
                            Text(filtro.rawValue).tag(filtro)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)

                    ScrollView {
                        LazyVStack(alignment: .leading, pinnedViews: [.sectionHeaders]) {
                            ForEach(grupos, id: \.self) { group in
                                Section(header: StickyHeaderView(date: group.date, saldo: saldosAcumulados[group.date] ?? 0.0)) {
                                    ForEach(group.lancamentos, id: \.id) { lancamento in
                                        HStack(alignment: .top, spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(lancamento.memo)
                                                    .font(.body)
                                                    .lineLimit(1)
                                                Text(lancamento.suggestedCategory)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            Text(lancamento.amount, format: .currency(code: "BRL"))
                                                .fontWeight(.bold)
                                                .foregroundColor(lancamento.amount >= 0 ? .green : .red)
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                    }
                                    .padding(.top, 4)
                                }
                            }
                        }
                    }
                }

                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    ProgressView("Carregando...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(12)
                }
            }
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.inline)
            .task { loadLancamentos() }
            .refreshable { await refreshLancamentos() }
        }
    }
    private func calcularSaldoDoDia(_ lancamentos: [LancamentoItem]) -> Double {
        lancamentos.reduce(0) { parcial, lancamento in
            parcial + lancamento.amount
        }
    }
    private func calcularSaldosAcumuladosPorDia(_ grupos: [LancamentosPorDia]) -> [Date: Double] {
        var saldoAcumulado = 0.0
        var resultado: [Date: Double] = [:]

        // Precisamos processar os dias em ordem crescente
        let gruposOrdenados = grupos.sorted { $0.date < $1.date }

        for grupo in gruposOrdenados {
            let saldoDoDia = grupo.lancamentos.reduce(0) { parcial, lancamento in
                parcial + lancamento.amount
            }
            saldoAcumulado += saldoDoDia
            resultado[grupo.date] = saldoAcumulado
        }

        return resultado
    }

    private func loadLancamentos() {
        let resultados = allLancamentos.filter { $0.accountName == account.name }
        lancamentos = Array(resultados)

        if resultados.isEmpty {
            Task { await refreshLancamentos() }
        }
    }

    private func refreshLancamentos() async {
        if isLoading { return }

        isLoading = true
        currentTask?.cancel()

        currentTask = Task {
            await fetchLancamentosFromAPI()
            await MainActor.run {
                loadLancamentos()
                isLoading = false
            }
        }
    }

    private func fetchLancamentosFromAPI() async {
        guard let accountNameEncoded = account.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://50917j6yoa.execute-api.sa-east-1.amazonaws.com/dev/transactions?account=\(accountNameEncoded)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(APIResponse.self, from: data)

            let realm = try await Realm()
            try realm.write {
                for (_, lancamentosDoMes) in decoded.transactions_by_month {
                    for remote in lancamentosDoMes {
                        let lancamento = LancamentoItem()
                        lancamento.id = remote.fitid
                        lancamento.accountName = account.name
                        lancamento.type = remote.type
                        lancamento.amount = remote.amount
                        lancamento.memo = remote.memo
                        lancamento.suggestedCategory = remote.suggested_category
                        lancamento.datePosted = parseDate(remote.date_posted)
                        realm.add(lancamento, update: .modified)
                    }
                }
            }
        } catch {
            print("Erro ao buscar lançamentos: \(error)")
        }
    }

    private func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: dateString) ?? Date()
    }

    private func lancamentosAgrupadosPorDia() -> [LancamentosPorDia] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let agrupados = Dictionary(grouping: lancamentosFiltrados()) { lancamento -> Date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: lancamento.datePosted)
            return Calendar.current.date(from: components) ?? Date()
        }

        let ordenados = agrupados.map { LancamentosPorDia(date: $0.key, lancamentos: $0.value) }
            .sorted { $0.date > $1.date }

        return ordenados
    }

    private func lancamentosFiltrados() -> [LancamentoItem] {
        let calendario = Calendar.current
        let hoje = Date()

        return lancamentos.filter { lancamento in
            switch filtroSelecionado {
            case .mesAtual:
                return calendario.isDate(lancamento.datePosted, equalTo: hoje, toGranularity: .month)
            case .mesAnterior:
                if let mesAnterior = calendario.date(byAdding: .month, value: -1, to: hoje) {
                    return calendario.isDate(lancamento.datePosted, equalTo: mesAnterior, toGranularity: .month)
                }
                return false
            case .ultimos6Meses:
                if let seisMesesAtras = calendario.date(byAdding: .month, value: -6, to: hoje) {
                    return lancamento.datePosted >= seisMesesAtras
                }
                return false
            case .esteAno:
                return calendario.isDate(lancamento.datePosted, equalTo: hoje, toGranularity: .year)
            }
        }
    }
}

struct APIResponse: Codable {
    let transactions_by_month: [String: [RemoteLancamento]]
}

struct LancamentosPorDia: Hashable {
    let date: Date
    let lancamentos: [LancamentoItem]
}
