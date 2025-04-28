import SwiftUI
import RealmSwift

struct AjusteSaldoInvestimentoSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: InvestmentDetailStore
    @State private var valor: String = ""
    @State private var valorFormatado: String = "0,00"
    @State private var data: Date = Date()
    @State private var errorMessage: String? = nil
    @FocusState private var isValorFocused: Bool
    
    private var saldoAtual: Double {
        store.investmentDetail?.currentBalance ?? 0.0
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
    
    private func formatInputValue(_ value: String) -> String {
        let numbers = value.filter { "0123456789".contains($0) }
        let double = Double(numbers) ?? 0
        return String(format: "%.2f", double / 100)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Saldo Atual
                VStack(spacing: 4) {
                    Text("Saldo Atual")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(saldoAtual))
                        .font(.title)
                        .bold()
                }
                .padding(.top, 8)
                
                // Campos de entrada
                VStack(spacing: 12) {
                    // Campo de valor
                    HStack {
                        Text("Novo Saldo")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("R$")
                                .foregroundColor(.secondary)
                            TextField("0,00", text: $valorFormatado)
                                .keyboardType(.numberPad)
                                .focused($isValorFocused)
                                .multilineTextAlignment(.leading)
                                .frame(width: 120)
                                .onChange(of: valorFormatado) { newValue in
                                    let filtered = newValue.filter { "0123456789,.".contains($0) }
                                    if filtered != newValue {
                                        valorFormatado = filtered
                                    }
                                    valor = filtered.filter { "0123456789".contains($0) }
                                    if !filtered.isEmpty {
                                        valorFormatado = formatInputValue(valor)
                                    }
                                }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    
                    // Data
                    HStack {
                        Text("Data do Ajuste")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        DatePicker("", selection: $data, displayedComponents: [.date])
                            .labelsHidden()
                            .frame(width: 120)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
            .navigationTitle("Ajustar Saldo")
            .navigationBarTitleDisplayMode(.inline)
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
            .onAppear {
                isValorFocused = true
            }
        }
        .presentationDetents([.height(280)]) // Reduzindo um pouco a altura
    }

    private func ajustarSaldo() {
        let valorNumerico = Double(valor) ?? 0
        guard valorNumerico > 0, let investimento = store.investmentDetail else {
            errorMessage = "Valor inválido."
            return
        }
        
        let novoSaldo = valorNumerico / 100
        let diferenca = novoSaldo - saldoAtual
        guard abs(diferenca) > 0.001 else {
            errorMessage = "O saldo informado é igual ao atual."
            return
        }
        
        do {
            let realm = try Realm()
            if let thawedInvestimento = investimento.thaw() {
                try realm.write {
                    thawedInvestimento.currentBalance = novoSaldo
                    let ajuste = InvestmentTransaction()
                    ajuste.id = UUID().uuidString
                    ajuste.descriptionText = "Ajuste de saldo manual"
                    ajuste.date = data
                    ajuste.value = diferenca
                    thawedInvestimento.transactions.append(ajuste)
                }
                Task {
                    await store.fetchInvestmentDetail(by: thawedInvestimento.id)
                    dismiss()
                }
            } else {
                errorMessage = "Não foi possível editar o investimento."
            }
        } catch {
            errorMessage = "Erro ao salvar ajuste."
        }
    }
}