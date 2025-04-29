import Foundation

// MARK: - Remote Account
struct RemoteAccount: Codable, Identifiable {
    let id: String
    let name: String
    let balance: Double
    let category: String
    let type: AccountType
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case balance
        case category
        case type
        case icon
    }
}

// MARK: - Account Type
enum AccountType: String, Codable {
    case conta = "conta"
    case investimento = "investimento"
    case cartao = "cartao"
}

// MARK: - Investment Types
enum InvestmentType: String, Codable {
    case cdb = "CDB"
    case stock = "STOCK"
    case fii = "FII"
    case crypto = "CRYPTO"
    case pension = "PENSION"
    case fgts = "FGTS"
}

// MARK: - Extensions
extension RemoteAccount {
    /// Converte o RemoteAccount para o modelo local Account
    func toLocalAccount() -> Account {
        return Account(
            id: self.id,
            name: self.name,
            balance: self.balance,
            category: self.category,
            icon: self.icon,
            type: self.type.rawValue
        )
    }
    
    /// Cria um RemoteAccount a partir do modelo local Account
    static func fromLocalAccount(_ account: Account) -> RemoteAccount {
        return RemoteAccount(
            id: account.id,
            name: account.name,
            balance: account.balance,
            category: account.category,
            type: AccountType(rawValue: account.type) ?? .conta,
            icon: account.icon
        )
    }
}
