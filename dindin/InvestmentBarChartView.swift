import SwiftUI
import Charts

struct InvestmentBarChartView: View {
    var dados: [InvestmentChartDataPoint]

    var body: some View {
        Chart(dados) { ponto in
            BarMark(
                x: .value("Data", ponto.date),
                y: .value("Valor", ponto.value)
            )
            .foregroundStyle(.blue)
        }
        .frame(height: 200)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}