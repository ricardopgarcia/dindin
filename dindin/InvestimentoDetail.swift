import Foundation
import RealmSwift

class InvestimentoDetail: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var type: String
    @Persisted var currentBalance: Double
    @Persisted var totalProfitability: Double
    @Persisted var annualProfitability: Double
    @Persisted var chartData = List<InvestmentChartDataPoint>()
    @Persisted var transactions = List<InvestmentTransaction>()
} 