import Foundation
import SwiftData

enum QRItemSource: String, Codable {
    case scanned
    case generated
}

enum QRContentType: String, Codable, CaseIterable, Identifiable {
    case text = "Texto"
    case url = "URL"
    case contact = "Contacto"
    case location = "Ubicación"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .contact: return "person.crop.circle"
        case .location: return "mappin.and.ellipse"
        }
    }

    var placeholder: String {
        switch self {
        case .text: return "Escribe tu texto aquí..."
        case .url: return "https://ejemplo.com"
        case .contact: return "BEGIN:VCARD\nVERSION:3.0\nFN:Nombre\nTEL:+34600000000\nEND:VCARD"
        case .location: return "geo:41.3851,2.1734"
        }
    }
}

@Model
final class QRItem {
    var id: UUID
    var content: String
    var source: QRItemSource
    var contentType: QRContentType
    var date: Date
    var foregroundColorHex: String
    var backgroundColorHex: String

    init(
        content: String,
        source: QRItemSource,
        contentType: QRContentType = .text,
        foregroundColorHex: String = "#000000",
        backgroundColorHex: String = "#FFFFFF"
    ) {
        self.id = UUID()
        self.content = content
        self.source = source
        self.contentType = contentType
        self.date = Date()
        self.foregroundColorHex = foregroundColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}
