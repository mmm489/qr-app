import SwiftUI

@Observable
final class GeneratorViewModel {
    var inputText: String = ""
    var selectedType: QRContentType = .text
    var foregroundColor: Color = .black
    var backgroundColor: Color = .white

    var qrImage: UIImage? {
        guard !inputText.isEmpty else { return nil }
        return QRGeneratorService.generate(
            from: inputText,
            foregroundColor: UIColor(foregroundColor),
            backgroundColor: UIColor(backgroundColor)
        )
    }

    var canGenerate: Bool {
        !inputText.isEmpty
    }

    /// Aplica la plantilla del tipo seleccionado al campo de texto.
    func applyPlaceholder() {
        inputText = selectedType.placeholder
    }

    /// Prepara el contenido formateado según el tipo.
    var formattedContent: String {
        switch selectedType {
        case .text:
            return inputText
        case .url:
            if inputText.hasPrefix("http://") || inputText.hasPrefix("https://") {
                return inputText
            }
            return "https://\(inputText)"
        case .contact:
            return inputText
        case .location:
            if inputText.hasPrefix("geo:") {
                return inputText
            }
            return "geo:\(inputText)"
        }
    }

    /// Genera la imagen QR con el contenido formateado.
    var formattedQRImage: UIImage? {
        guard !inputText.isEmpty else { return nil }
        return QRGeneratorService.generate(
            from: formattedContent,
            foregroundColor: UIColor(foregroundColor),
            backgroundColor: UIColor(backgroundColor)
        )
    }

    /// Hex strings para persistencia.
    var foregroundHex: String {
        UIColor(foregroundColor).toHex()
    }

    var backgroundHex: String {
        UIColor(backgroundColor).toHex()
    }
}
