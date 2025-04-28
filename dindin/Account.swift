import Foundation
import RealmSwift

class Account: Object, Identifiable {
    @Persisted(primaryKey: true) var id: String // ✅ Aqui é a correção!
    @Persisted var name: String
    @Persisted var balance: Double
    @Persisted var category: String
    @Persisted var icon: String
    @Persisted var type: String = "" // novo campo
    @Persisted var isSynced: Bool = true
}
