import SwiftUI
import SwiftData

struct GeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = GeneratorViewModel()
    @State private var showShareSheet = false
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview del QR
                    qrPreview

                    // Selector de tipo
                    typeSelector

                    // Campo de texto
                    inputField

                    // Selectores de color
                    colorPickers

                    // Botones de acción
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Crear QR")
            .sheet(isPresented: $showShareSheet) {
                if let image = viewModel.formattedQRImage {
                    ShareSheet(items: [image])
                }
            }
            .alert("Guardado", isPresented: $showSavedAlert) {
                Button("OK") {}
            } message: {
                Text("El QR se ha guardado en el historial.")
            }
        }
    }

    // MARK: - Subviews

    private var qrPreview: some View {
        QRCodeView(
            content: viewModel.formattedContent,
            foregroundColor: viewModel.foregroundColor,
            backgroundColor: viewModel.backgroundColor,
            size: 250
        )
        .shadow(color: .black.opacity(0.1), radius: 10)
        .animation(.easeInOut(duration: 0.2), value: viewModel.inputText)
        .animation(.easeInOut(duration: 0.2), value: viewModel.foregroundColor)
        .animation(.easeInOut(duration: 0.2), value: viewModel.backgroundColor)
    }

    private var typeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tipo de contenido")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(QRContentType.allCases) { type in
                        Button {
                            viewModel.selectedType = type
                            viewModel.inputText = ""
                        } label: {
                            Label(type.rawValue, systemImage: type.icon)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    viewModel.selectedType == type
                                        ? Color.blue
                                        : Color(.systemGray5)
                                )
                                .foregroundStyle(
                                    viewModel.selectedType == type
                                        ? .white
                                        : .primary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var inputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Contenido")
                .font(.headline)

            if viewModel.selectedType == .contact {
                TextEditor(text: $viewModel.inputText)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            } else {
                TextField(viewModel.selectedType.placeholder, text: $viewModel.inputText)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            if viewModel.selectedType == .contact {
                Button("Usar plantilla vCard") {
                    viewModel.applyPlaceholder()
                }
                .font(.caption)
            }
        }
    }

    private var colorPickers: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Personalizar colores")
                .font(.headline)

            HStack(spacing: 20) {
                ColorPicker("QR", selection: $viewModel.foregroundColor, supportsOpacity: false)
                ColorPicker("Fondo", selection: $viewModel.backgroundColor, supportsOpacity: false)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showShareSheet = true
            } label: {
                Label("Compartir QR", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canGenerate)

            Button {
                saveToHistory()
            } label: {
                Label("Guardar en historial", systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canGenerate)
        }
    }

    // MARK: - Actions

    private func saveToHistory() {
        let item = QRItem(
            content: viewModel.formattedContent,
            source: .generated,
            contentType: viewModel.selectedType,
            foregroundColorHex: viewModel.foregroundHex,
            backgroundColorHex: viewModel.backgroundHex
        )
        modelContext.insert(item)
        showSavedAlert = true
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    GeneratorView()
        .modelContainer(for: QRItem.self, inMemory: true)
}
