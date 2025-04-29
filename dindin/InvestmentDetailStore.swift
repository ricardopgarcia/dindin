import Foundation
import RealmSwift

class InvestmentDetailStore: ObservableObject {
    @Published var investmentDetail: InvestimentoDetail?
    @Published var errorMessage: String?
    private var realm: Realm

    init() {
        do {
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            print("✅ InvestmentDetailStore inicializado com Realm.")
        } catch {
            print("⚠️ Erro ao iniciar Realm: \(error)")
            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            realm = try! Realm()
        }
    }

    @MainActor
    func fetchInvestmentDetail(by id: String) async {
        errorMessage = nil
        print("[InvestmentDetailStore] fetchInvestmentDetail chamado com id: \(id)")
        print("📦 Buscando detalhes locais do investimento \(id)...")

        if let localDetail = realm.object(ofType: InvestimentoDetail.self, forPrimaryKey: id) {
            print("✅ Detalhe encontrado localmente.")
            self.investmentDetail = localDetail.freeze()
        } else {
            print("🌐 Detalhe não encontrado localmente. Chamando API...")
            await fetchInvestmentDetailFromAPI(id: id)
        }
    }

    @MainActor
    func fetchInvestmentDetailFromAPI(id: String) async {
        print("[InvestmentDetailStore] fetchInvestmentDetailFromAPI chamado com id: \(id)")
        guard let url = URL(string: "https://50917j6yoa.execute-api.sa-east-1.amazonaws.com/dev/investments/\(id)") else {
            print("❌ URL inválida para investimento \(id)")
            errorMessage = "URL inválida para o investimento."
            return
        }

        do {
            print("🌐 Antes de chamar API para investimento \(id)")
            let (data, response) = try await URLSession.shared.data(from: url)
            print("🌐 Depois de chamar API para investimento \(id)")
            print("🌐 Dados brutos da API: \(String(data: data, encoding: .utf8) ?? "nil")")
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ Erro ao chamar API de detalhes para \(id)")
                if let apiError = try? JSONDecoder().decode([String: String].self, from: data), let msg = apiError["error"] {
                    errorMessage = msg
                } else {
                    errorMessage = "Não foi possível carregar os dados do investimento. Tente novamente."
                }
                return
            }

            let remoteDetail = try JSONDecoder().decode(RemoteStockDetail.self, from: data)
            print("✅ Dados recebidos da API para \(id). Atualizando Realm...")

            try? realm.write {
                let detail = InvestimentoDetail()
                detail.id = remoteDetail.accountId
                detail.name = remoteDetail.accountName
                detail.type = "investimento"
                detail.totalProfitability = remoteDetail.toBaseInvestment().totalProfitability
                detail.annualProfitability = remoteDetail.toBaseInvestment().annualProfitability

                // Adiciona os pontos do gráfico
                let chartData: [InvestmentChartDataPoint] = remoteDetail.chartData.map {
                    let point = InvestmentChartDataPoint()
                    point.date = ISO8601DateFormatter().date(from: $0.date) ?? Date()
                    point.value = $0.value
                    return point
                }
                detail.chartData.removeAll()
                detail.chartData.append(objectsIn: chartData)

                // Adiciona as transações
                let transactions: [InvestmentTransaction] = remoteDetail.transactions.map {
                    let tx = InvestmentTransaction()
                    tx.id = $0.id
                    tx.descriptionText = $0.description
                    tx.date = ISO8601DateFormatter().date(from: $0.date) ?? Date()
                    tx.value = $0.value
                    return tx
                }
                detail.transactions.removeAll()
                detail.transactions.append(objectsIn: transactions)

                // Define o saldo atual como o último valor do gráfico
                if let lastPoint = remoteDetail.chartData.last {
                    detail.currentBalance = lastPoint.value
                }

                realm.add(detail, update: .modified)
            }
            print("✅ InvestimentoDetail salvo no Realm. Total agora: \(realm.objects(InvestimentoDetail.self).count)")
            await fetchInvestmentDetail(by: id)

        } catch {
            print("❌ Erro ao buscar detalhes do investimento \(id): \(error)")
            errorMessage = "Erro ao buscar detalhes do investimento. Tente novamente."
        }
    }
}

// MARK: - API Response Models
struct RemoteInvestmentDetail: Decodable {
    let accountName: String
    let accountId: String
    let profitability: RemoteProfitability
    let chartData: [RemoteChartDataPoint]
    let transactions: [RemoteTransaction]

    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case accountId = "account_id"
        case profitability
        case chartData = "chart_data"
        case transactions
    }
}

struct RemoteProfitability: Decodable {
    let total: Double
    let annual: Double
    let period: RemotePeriod
}

struct RemotePeriod: Decodable {
    let startDate: String
    let endDate: String

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

struct RemoteChartDataPoint: Decodable {
    let date: String
    let value: Double
}

struct RemoteTransaction: Decodable {
    let id: String
    let description: String
    let date: String
    let value: Double
}
