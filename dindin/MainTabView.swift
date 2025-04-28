
import SwiftUI

struct MainTabView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @StateObject private var store = AccountStore()

    var body: some View {
        TabView {
            SaldoView(store: store)
                .tabItem {
                    Label("Saldo", systemImage: "scalemass")
                }

            Text("Orçamento")
                .tabItem {
                    Label("Orçamento", systemImage: "chart.pie")
                }

            Text("Relatórios")
                .tabItem {
                    Label("Relatórios", systemImage: "chart.bar.xaxis")
                }

            NavigationView {
                VStack(spacing: 20) {
                    Text("Configurações e Mais")
                        .font(.title2)

                    Button(role: .destructive) {
                        AuthManager.shared.logout()
                        isLoggedIn = false
                    } label: {
                        Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                .padding()
                .navigationTitle("Mais")
            }
            .tabItem {
                Label("Mais", systemImage: "gearshape")
            }
        }
    }
}
