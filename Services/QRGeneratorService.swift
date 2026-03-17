import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct QRGeneratorService {

    /// Genera una UIImage de código QR a partir de un string con colores personalizados.
    static func generate(
        from string: String,
        foregroundColor: UIColor = .black,
        backgroundColor: UIColor = .white,
        size: CGFloat = 1024
    ) -> UIImage? {
        let context = CIContext()

        // 1. Generar el QR en blanco y negro
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let data = string.data(using: .utf8)
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("H", forKey: "inputCorrectionLevel") // Alta corrección de errores

        guard let qrImage = qrFilter.outputImage else { return nil }

        // 2. Aplicar colores personalizados
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        colorFilter.setValue(qrImage, forKey: "inputImage")
        colorFilter.setValue(CIColor(color: foregroundColor), forKey: "inputColor0")
        colorFilter.setValue(CIColor(color: backgroundColor), forKey: "inputColor1")

        guard let coloredImage = colorFilter.outputImage else { return nil }

        // 3. Escalar a tamaño deseado
        let scaleX = size / coloredImage.extent.size.width
        let scaleY = size / coloredImage.extent.size.height
        let scaledImage = coloredImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        // 4. Renderizar a UIImage
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
