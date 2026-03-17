import SwiftUI
import SwiftData

@main
struct QRApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: QRItem.self)
    }
}
