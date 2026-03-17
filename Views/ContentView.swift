import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScannerView()
                .tabItem {
                    Label("Escanear", systemImage: "qrcode.viewfinder")
                }

            GeneratorView()
                .tabItem {
                    Label("Crear", systemImage: "plus.viewfinder")
                }

            HistoryView()
                .tabItem {
                    Label("Historial", systemImage: "clock.arrow.circlepath")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QRItem.self, inMemory: true)
}
