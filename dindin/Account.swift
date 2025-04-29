import Foundation
import RealmSwift

class Account: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String
    @Persisted var name: String
    @Persisted var balance: Double
    @Persisted var category: String
    @Persisted var icon: String
    @Persisted var type: String
    @Persisted var isSynced: Bool = true
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id: String, name: String, balance: Double, category: String, icon: String, type: String) {
        self.init()
        self.id = id
        self.name = name
        self.balance = balance
        self.category = category
        self.icon = icon
        self.type = type
        self.isSynced = true
    }
}
