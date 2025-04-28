import SwiftUI

@main
struct DindinApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                showSplash = false
                            }
                        }
                } else {
                    if isLoggedIn {
                        MainTabView()
                    } else {
                        LoginView()
                    }
                }
            }
        }
    }
}
