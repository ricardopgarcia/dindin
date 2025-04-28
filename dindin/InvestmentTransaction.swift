import Foundation
import RealmSwift

class InvestmentTransaction: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var descriptionText: String = ""
    @Persisted var date: Date = Date()
    @Persisted var value: Double = 0.0
}