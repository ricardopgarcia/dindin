
import SwiftUI

struct InvestmentChartSelectorView: View {
    @Binding var selectedPeriod: Period

    let periods: [Period] = [.oneMonth, .sixMonths, .oneYear, .fiveYears]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(periods, id: \.self) { period in
                Button(action: {
                    selectedPeriod = period
                }) {
                    Text(period.rawValue)
                        .font(.subheadline)
                        .fontWeight(selectedPeriod == period ? .bold : .regular)
                        .foregroundColor(selectedPeriod == period ? .blue : .primary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            selectedPeriod == period ? Color.blue.opacity(0.2) : Color.clear
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}
