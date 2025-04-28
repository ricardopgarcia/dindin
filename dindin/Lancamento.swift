import Foundation
import RealmSwift

class LancamentoItem: Object, Identifiable { // Renomeado para evitar conflito
    @Persisted(primaryKey: true) var id: String
    @Persisted var accountName: String
    @Persisted var type: String
    @Persisted var datePosted: Date
    @Persisted var amount: Double
    @Persisted var memo: String
    @Persisted var suggestedCategory: String
}
