import SwiftUI

enum Tab: Int, CaseIterable {
    case scan, create, history

    var title: String {
        switch self {
        case .scan: return "Escanear"
        case .create: return "Crear"
        case .history: return "Historial"
        }
    }

    var icon: String {
        switch self {
        case .scan: return "qrcode.viewfinder"
        case .create: return "plus.viewfinder"
        case .history: return "clock.arrow.circlepath"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: Tab = .scan
    @Namespace private var tabAnimation

    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenido
            Group {
                switch selectedTab {
                case .scan:
                    ScannerView()
                case .create:
                    GeneratorView()
                case .history:
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Tab bar glassmorphism
            glassTabBar
        }
        .ignoresSafeArea(.keyboard)
    }

    private var glassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == tab {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 32)
                            .matchedGeometryEffect(id: "tabHighlight", in: tabAnimation)
                            .shadow(color: .purple.opacity(0.4), radius: 8, y: 4)
                    }

                    Image(systemName: tab.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : .secondary)
                        .frame(width: 56, height: 32)
                }

                Text(tab.title)
                    .font(.system(size: 10, weight: selectedTab == tab ? .bold : .medium))
                    .foregroundStyle(selectedTab == tab ? .primary : .secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QRItem.self, inMemory: true)
}
