import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QRItem.date, order: .reverse) private var items: [QRItem]
    @State private var selectedItem: QRItem?
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("Historial")
            .sheet(item: $selectedItem) { item in
                historyDetail(item)
                    .presentationDetents([.medium, .large])
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Sin historial")
                .font(.title3.bold())
            Text("Los QRs que escanees o crees aparecerán aquí.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var itemList: some View {
        List {
            ForEach(items) { item in
                Button {
                    selectedItem = item
                } label: {
                    HStack(spacing: 14) {
                        // Mini QR preview
                        QRCodeView(
                            content: item.content,
                            foregroundColor: Color(hex: item.foregroundColorHex) ?? .black,
                            backgroundColor: Color(hex: item.backgroundColorHex) ?? .white,
                            size: 50
                        )
                        .frame(width: 50, height: 50)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: item.source == .scanned ? "qrcode.viewfinder" : "plus.viewfinder")
                                    .foregroundStyle(item.source == .scanned ? .blue : .green)
                                Text(item.source == .scanned ? "Escaneado" : "Generado")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text(item.content)
                                .font(.subheadline)
                                .lineLimit(2)
                                .foregroundStyle(.primary)

                            Text(item.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }

                        Spacer()

                        Image(systemName: item.contentType.icon)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.insetGrouped)
    }

    private func historyDetail(_ item: QRItem) -> some View {
        NavigationStack {
            VStack(spacing: 20) {
                QRCodeView(
                    content: item.content,
                    foregroundColor: Color(hex: item.foregroundColorHex) ?? .black,
                    backgroundColor: Color(hex: item.backgroundColorHex) ?? .white,
                    size: 250
                )

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(item.contentType.rawValue, systemImage: item.contentType.icon)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(item.content)
                            .font(.body)
                            .textSelection(.enabled)

                        Text(item.date.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                HStack(spacing: 12) {
                    Button {
                        UIPasteboard.general.string = item.content
                    } label: {
                        Label("Copiar", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Compartir", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showShareSheet) {
                if let image = QRGeneratorService.generate(
                    from: item.content,
                    foregroundColor: UIColor(Color(hex: item.foregroundColorHex) ?? .black),
                    backgroundColor: UIColor(Color(hex: item.backgroundColorHex) ?? .white)
                ) {
                    ShareSheet(items: [image])
                }
            }
        }
    }

    // MARK: - Actions

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: QRItem.self, inMemory: true)
}
