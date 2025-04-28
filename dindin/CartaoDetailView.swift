import SwiftUI

struct CartaoDetailView: View {
    let account: Account

    @State private var faturas: [Fatura] = Fatura.mockFaturas()
    @State private var faturaSelecionada: Fatura?

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text(account.name)
                    .font(.title2)
                    .bold()

                if let atual = faturaSelecionada {
                    HStack(spacing: 8) {
                        Text("R$ \(atual.totalFatura(), specifier: "%.2f")")
                            .font(.title3)
                            .bold()
                        statusBadge(for: atual.status)
                    }
                }
            }
            .padding(.top)

            Menu {
                ForEach(faturas, id: \.self) { fatura in
                    Button(action: {
                        withAnimation {
                            faturaSelecionada = fatura
                        }
                    }) {
                        HStack {
                            Text(fatura.mesAno)
                            Spacer()
                            statusBadge(for: fatura.status)
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Fatura: \(faturaSelecionada?.mesAno ?? "Selecionar")")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(90))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Divider()

            if let lancamentos = faturaSelecionada?.lancamentos, !lancamentos.isEmpty {
                List(lancamentos) { lancamento in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lancamento.descricao)
                            .font(.headline)
                        HStack {
                            Text(lancamento.data, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("R$ \(lancamento.valor, specifier: "%.2f")")
                                .bold()
                                .foregroundColor(lancamento.valor < 0 ? .green : .red)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
                .transition(.opacity)
            } else {
                VStack {
                    Spacer()
                    Text("Nenhum lançamento nesta fatura.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .transition(.opacity)
            }

            Spacer()
        }
        .background(
            Color(.systemBackground)
        )
        .navigationTitle("Cartão")
        .onAppear {
            if let atual = faturas.first(where: { $0.status == .parcial }) {
                faturaSelecionada = atual
            } else {
                faturaSelecionada = faturas.first
            }
        }
    }

    private func statusBadge(for status: FaturaStatus) -> some View {
        switch status {
        case .fechada:
            return Text("Fechada")
                .font(.caption2)
                .padding(4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
        case .parcial:
            return Text("Parcial")
                .font(.caption2)
                .padding(4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        case .futura:
            return Text("Futura")
                .font(.caption2)
                .padding(4)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

struct Fatura: Hashable {
    let mesAno: String
    let status: FaturaStatus
    let lancamentos: [Lancamento]

    static func mockFaturas() -> [Fatura] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        return [
            Fatura(mesAno: "01/2025", status: .fechada, lancamentos: [
                Lancamento(descricao: "Mercado", valor: -250.00, data: formatter.date(from: "2025/01/05")!),
                Lancamento(descricao: "Posto de Gasolina", valor: -180.00, data: formatter.date(from: "2025/01/10")!)
            ]),
            Fatura(mesAno: "02/2025", status: .fechada, lancamentos: [
                Lancamento(descricao: "Cinema", valor: -50.00, data: formatter.date(from: "2025/02/12")!)
            ]),
            Fatura(mesAno: "03/2025", status: .fechada, lancamentos: [
                Lancamento(descricao: "Academia", valor: -120.00, data: formatter.date(from: "2025/03/01")!)
            ]),
            Fatura(mesAno: "04/2025", status: .parcial, lancamentos: [
                Lancamento(descricao: "Supermercado", valor: -320.00, data: formatter.date(from: "2025/04/02")!),
                Lancamento(descricao: "Farmácia", valor: -85.00, data: formatter.date(from: "2025/04/03")!)
            ]),
            Fatura(mesAno: "05/2025", status: .futura, lancamentos: []),
            Fatura(mesAno: "06/2025", status: .futura, lancamentos: []),
            Fatura(mesAno: "07/2025", status: .futura, lancamentos: [])
        ]
    }

    func totalFatura() -> Double {
        lancamentos.map { $0.valor }.reduce(0, +)
    }
}

enum FaturaStatus: String {
    case fechada
    case parcial
    case futura
}

struct Lancamento: Identifiable, Hashable {
    let id = UUID()
    let descricao: String
    let valor: Double
    let data: Date
}