import SwiftUI
import Charts

struct InvestmentChartView: View {
    var dados: [InvestmentDataPoint]

    var body: some View {
        Chart(dados) { ponto in
            LineMark(
                x: .value("Data", ponto.date),
                y: .value("Valor", ponto.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(.blue)
            .symbol(Circle())
        }
        .frame(height: 200)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}