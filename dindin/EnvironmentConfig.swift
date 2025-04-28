
import Foundation

struct EnvironmentConfig {
    static let currentEnvironment: Environment = .dev

    enum Environment {
        case dev
        case prod
    }

    static var apiBaseURL: String {
        switch currentEnvironment {
        case .dev:
            return "https://50917j6yoa.execute-api.sa-east-1.amazonaws.com/dev"
        case .prod:
            return "https://sua-api-real.com/prod"
        }
    }

    static var accountsEndpoint: String {
        return "\(apiBaseURL)/accounts"
    }
}
