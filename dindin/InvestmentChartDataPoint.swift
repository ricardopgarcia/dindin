import Foundation
import RealmSwift

class InvestmentChartDataPoint: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var date: Date
    @Persisted var value: Double
}