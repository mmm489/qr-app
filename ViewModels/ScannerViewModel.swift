import SwiftUI
import AVFoundation

@Observable
final class ScannerViewModel {
    var scannedCode: String?
    var isScanning: Bool = true
    var permissionGranted: Bool = false
    var showPermissionAlert: Bool = false

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.permissionGranted = granted
                    if !granted {
                        self?.showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            permissionGranted = false
            showPermissionAlert = true
        @unknown default:
            permissionGranted = false
        }
    }

    func onCodeScanned(_ code: String) {
        scannedCode = code
        isScanning = false
    }

    func restartScanning() {
        scannedCode = nil
        isScanning = true
    }

    /// Detecta el tipo de contenido del QR escaneado.
    var detectedContentType: QRContentType {
        guard let code = scannedCode else { return .text }
        if code.hasPrefix("http://") || code.hasPrefix("https://") {
            return .url
        } else if code.hasPrefix("BEGIN:VCARD") {
            return .contact
        } else if code.hasPrefix("geo:") {
            return .location
        }
        return .text
    }

    /// Abre la URL en el navegador si es una URL válida.
    func openURL() {
        guard let code = scannedCode,
              let url = URL(string: code),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    /// Copia el contenido al portapapeles.
    func copyToClipboard() {
        guard let code = scannedCode else { return }
        UIPasteboard.general.string = code
    }
}
