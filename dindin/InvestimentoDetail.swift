import Foundation
import RealmSwift

class InvestimentoDetail: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var type: String
    @Persisted var category: String
    @Persisted var currentBalance: Double
    @Persisted var initialInvestment: Double
    @Persisted var totalProfitability: Double
    @Persisted var annualProfitability: Double
    @Persisted var liquidity: String
    @Persisted var maturityDate: Date
    @Persisted var chartData = List<InvestmentChartDataPoint>()
    @Persisted var transactions = List<InvestmentTransaction>()
} 