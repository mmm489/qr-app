import SwiftUI

/// Componente reutilizable que muestra un código QR como imagen.
struct QRCodeView: View {
    let content: String
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white
    var size: CGFloat = 250

    var body: some View {
        if let uiImage = QRGeneratorService.generate(
            from: content,
            foregroundColor: UIColor(foregroundColor),
            backgroundColor: UIColor(backgroundColor),
            size: size
        ) {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray5))
                .frame(width: size, height: size)
                .overlay {
                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Introduce texto para generar el QR")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
        }
    }
}

#Preview {
    QRCodeView(content: "https://apple.com")
}
