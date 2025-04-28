import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0

    var body: some View {
        VStack {
            Spacer()
            Image("SplashIcon") // Imagem adicionada em Assets
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }

            Text("Gestor Financeiro")
                .font(.largeTitle)
                .bold()
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.5).delay(0.3)) {
                        opacity = 1.0
                    }
                }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}