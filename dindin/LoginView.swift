import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var authErrorMessage = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer(minLength: 60)

                    Text("Entrar com biometria")
                        .font(.title2)

                    Button(action: authenticateWithBiometrics) {
                        Image(systemName: "faceid")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .padding()
                    }

                    Divider().padding(.horizontal)

                    Text("Ou faça login manual")
                        .font(.subheadline)

                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Senha", text: $password)
                        .textFieldStyle(.roundedBorder)

                    Button("Entrar") {
                        if AuthManager.shared.login(email: email, password: password) {
                            isLoggedIn = true
                        } else {
                            authErrorMessage = "Credenciais inválidas"
                            showAlert = true
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    NavigationLink("Criar conta", destination: SignUpView())

                    Spacer(minLength: 60)
                }
                .padding()
            }
            .navigationTitle("Login")
            .alert("Erro", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authErrorMessage)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }

    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentique-se para acessar o Dindin"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        isLoggedIn = true
                    } else {
                        authErrorMessage = "Falha na autenticação biométrica"
                        showAlert = true
                    }
                }
            }
        } else {
            authErrorMessage = "Biometria não disponível neste dispositivo"
            showAlert = true
        }
    }
}