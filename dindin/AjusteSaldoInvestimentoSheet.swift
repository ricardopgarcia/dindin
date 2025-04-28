import SwiftUI
import RealmSwift

struct AjusteSaldoInvestimentoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: InvestmentDetailStore
    @State private var valor: String = ""
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Novo Saldo")) {
                    TextField("Valor", text: $valor)
                        .keyboardType(.decimalPad)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Ajustar Saldo")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        ajustarSaldo()
                    }
                    .disabled(valor.isEmpty)
                }
            }
        }
    }

    private func ajustarSaldo() {
        guard let novoSaldo = Double(valor.replacingOccurrences(of: ",", with: ".")), let investimento = store.investmentDetail else {
            errorMessage = "Valor inválido."
            print("Valor inválido")
            return
        }
        let saldoAtual = investimento.currentBalance
        let diferenca = novoSaldo - saldoAtual
        guard abs(diferenca) > 0.001 else {
            errorMessage = "O saldo informado é igual ao atual."
            print("Saldo igual ao atual")
            return
        }
        do {
            let realm = try Realm()
            if let thawedInvestimento = investimento.thaw() {
                try realm.write {
                    print("Atualizando saldo e criando transação")
                    thawedInvestimento.currentBalance = novoSaldo
                    let ajuste = InvestmentTransaction()
                    ajuste.id = UUID().uuidString
                    ajuste.descriptionText = "Ajuste de saldo manual"
                    ajuste.date = Date()
                    ajuste.value = diferenca
                    thawedInvestimento.transactions.append(ajuste)
                }
                print("Ajuste realizado com sucesso")
                // Recarrega o investimento para refletir as mudanças
                Task {
                    await store.fetchInvestmentDetail(by: thawedInvestimento.id)
                    dismiss()
                }
            } else {
                errorMessage = "Não foi possível editar o investimento (objeto congelado)."
                print("Objeto congelado")
            }
        } catch {
            errorMessage = "Erro ao salvar ajuste."
            print("Erro ao salvar ajuste: \(error)")
        }
    }
}