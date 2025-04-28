import SwiftUI
import Charts

struct InvestmentComparisonChartView: View {
    var dados: [InvestmentChartDataPoint]

    var body: some View {
        Chart(dados) { ponto in
            LineMark(
                x: .value("Data", ponto.date),
                y: .value("Valor", ponto.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.green)
            .symbol(Circle())
        }
        .frame(height: 200)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}