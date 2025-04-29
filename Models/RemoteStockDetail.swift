import Foundation

struct RemoteStockDetail: Codable {
    let accountId: String
    let accountName: String
    let toBaseInvestment: BaseInvestment
}

struct BaseInvestment: Codable {
    let totalProfitability: Double
    let annualProfitability: Double
} 