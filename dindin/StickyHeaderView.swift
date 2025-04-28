import SwiftUI

struct StickyHeaderView: View {
    var date: Date
    var saldo: Double

    private var headerDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.setLocalizedDateFormatFromTemplate("EEEE, d MMMM")
        return formatter
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(headerDateFormatter.string(from: date).capitalized)
                    .font(.caption.bold()) // Título do dia menor e negrito
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(saldo, format: .currency(code: "BRL"))
                    .font(.caption) // Saldo discreto
                    .foregroundColor(saldo >= 0 ? .green : .red)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)

            Divider()
                .background(Color.secondary.opacity(0.4))
                .padding(.horizontal)
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    StickyHeaderView(date: Date(), saldo: 1000)
}
