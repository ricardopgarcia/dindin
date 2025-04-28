import SwiftUI
import RealmSwift

struct AddEditAccountView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var accountStore: AccountStore
    var accountToEdit: Account?

    @State private var name: String = ""
    @State private var balance: String = ""
    @State private var icon: String = "banknote"
    @State private var category: String = "Contas"

    let categories = [
        "Espécie", "Contas", "Cartões",
        "CDBs", "LCIs", "LCAs",
        "Fundos de Renda Fixa", "Fundos de Renda Variável",
        "Ações", "FIIs", "Criptomoedas"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nome da Conta")) {
                    TextField("Ex: Conta Corrente", text: $name)
                }

                Section(header: Text("Saldo")) {
                    TextField("R$ 0,00", text: $balance)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Ícone")) {
                    TextField("Ex: creditcard", text: $icon)
                }

                Section(header: Text("Categoria")) {
                    Picker("Categoria", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }

                Button(action: saveAccount) {
                    Text(accountToEdit == nil ? "Adicionar Conta" : "Salvar Alterações")
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(accountToEdit == nil ? "Nova Conta" : "Editar Conta")
            .navigationBarItems(leading: Button("Cancelar") {
                dismiss()
            })
            .onAppear {
                if let account = accountToEdit {
                    name = account.name
                    balance = String(account.balance)
                    icon = account.icon
                    category = account.category
                }
            }
        }
    }

    private func saveAccount() {
        guard let saldo = Double(balance.replacingOccurrences(of: ",", with: ".")) else { return }

        
        dismiss()
    }
}
