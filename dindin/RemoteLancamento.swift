
import Foundation

struct RemoteLancamento: Codable {
    var type: String
    var date_posted: String
    var amount: Double
    var fitid: String
    var memo: String
    var suggested_category: String
}
