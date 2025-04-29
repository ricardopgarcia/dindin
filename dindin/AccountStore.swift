import Foundation
import RealmSwift

class AccountStore: ObservableObject {
    @Published var accounts: [Account] = []
    private var realm: Realm
    private var networkTimer: Timer?
    private var isMonitoringNetwork = false

    private let syncIntervalSeconds: TimeInterval = 120

    init() {
        do {
            let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            print("✅ AccountStore inicializado com Realm.")
        } catch {
            print("⚠️ Erro ao iniciar Realm, tentando recriar o banco. Erro: \(error)")
            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            realm = try! Realm()
        }

        loadAccounts()

        if accounts.isEmpty {
            Task {
                print("🔄 Contas locais vazias. Buscando da API...")
                await fetchAccountsFromAPI()
            }
        }
    }

    private func loadAccounts() {
        print("📦 Buscando contas locais (Realm)")
        accounts = Array(realm.objects(Account.self))
        print("✅ Contas carregadas do Realm: \(accounts.count)")
    }

    func addAccount(_ account: Account) {
        print("➕ Adicionando nova conta localmente: \(account.name)")
        try! realm.write {
            realm.add(account, update: .modified)
        }
        loadAccounts()
    }

    func updateAccount(_ account: Account) {
        print("✏️ Atualizando conta localmente: \(account.name)")
        try! realm.write {
            realm.add(account, update: .modified)
        }
        loadAccounts()
    }

    func fetchAccountsFromAPI() async {
        guard let url = URL(string: EnvironmentConfig.accountsEndpoint) else {
            print("❌ URL inválida")
            return
        }

        print("🌐 [API] Iniciando chamada para buscar contas...")
        let startTime = Date()

        print("🌎 [DEBUG] Preparando para chamar a URL: \(url.absoluteString)")
        print("⌛ [DEBUG] Aguardando resposta da API...")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ [API] Resposta inválida")
                return
            }

            if httpResponse.statusCode == 200 {
                let remoteAccounts = try JSONDecoder().decode([RemoteAccount].self, from: data)
                print("✅ [API] Contas recebidas da API - quantidade: \(remoteAccounts.count)")

                // Debug: Imprimir o JSON recebido
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 [DEBUG] JSON recebido: \(jsonString)")
                }

                await MainActor.run {
                    self.updateLocalAccounts(with: remoteAccounts)
                }
            } else {
                print("❌ [API] Erro da API - StatusCode: \(httpResponse.statusCode)")
            }

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ [API] Requisição cancelada (não é erro)")
                return
            }

            print("❌ [API] Erro ao buscar contas: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("🔍 Detalhes do erro de decodificação: \(decodingError)")
                
                // Debug: Imprimir o JSON recebido em caso de erro
                if let data = try? error.localizedDescription.data(using: .utf8),
                   let jsonString = String(data: data, encoding: .utf8) {
                    print("📄 [DEBUG] JSON com erro: \(jsonString)")
                }
            }
        }

        let elapsed = Date().timeIntervalSince(startTime)
        print("⏱️ [API] Tempo total da chamada: \(String(format: "%.2f", elapsed)) segundos")
    }

    private func updateLocalAccounts(with remoteAccounts: [RemoteAccount]) {
        print("📥 Atualizando contas locais com dados da API")

        do {
            try realm.write {
                // Remove todas as contas existentes
                realm.delete(realm.objects(Account.self))
                
                // Adiciona as novas contas usando o método de conversão
                for remote in remoteAccounts {
                    let account = remote.toLocalAccount()
                    realm.add(account, update: .modified)
                }
            }
            print("✅ Contas atualizadas no Realm")
            loadAccounts()
        } catch {
            print("❌ Erro ao atualizar contas no Realm: \(error)")
        }

        print("🏁 Sincronização de contas finalizada")
    }

    func startMonitoringNetwork() {
        guard !isMonitoringNetwork else { return }

        print("📶 Iniciando monitoramento de rede para sincronizar pendências...")
        isMonitoringNetwork = true

        networkTimer = Timer.scheduledTimer(withTimeInterval: syncIntervalSeconds, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if NetworkMonitor.shared.isConnected {
                print("📡 Rede online, tentando sincronizar pendências...")
                self.syncPendingAccounts()
            } else {
                print("📴 Rede offline, aguardando reconexão...")
            }
        }
    }

    func stopMonitoringNetwork() {
        print("🛑 Parando monitoramento de rede.")
        networkTimer?.invalidate()
        networkTimer = nil
        isMonitoringNetwork = false
    }

    func syncPendingAccounts() {
        print("🔄 Buscando contas pendentes para sincronizar...")
        let pendingAccounts = realm.objects(Account.self).filter("isSynced == false")
        print("Encontradas \(pendingAccounts.count) contas pendentes.")

        do {
            try realm.write {
                for account in pendingAccounts {
                    account.isSynced = true
                }
            }
            print("✅ Contas pendentes marcadas como sincronizadas")
            loadAccounts()
        } catch {
            print("❌ Erro ao sincronizar contas pendentes: \(error)")
        }
    }
}
