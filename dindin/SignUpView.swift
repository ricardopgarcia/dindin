import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Criar Conta")
                .font(.title)
                .bold()

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)

            SecureField("Senha", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirmar Senha", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)

            Button("Cadastrar") {
                guard password == confirmPassword else {
                    alertMessage = "As senhas não coincidem"
                    showAlert = true
                    return
                }

                if AuthManager.shared.register(email: email, password: password) {
                    dismiss()
                } else {
                    alertMessage = "E-mail já cadastrado"
                    showAlert = true
                }
            }
            .buttonStyle(.borderedProminent)
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
        .padding()
    }
}