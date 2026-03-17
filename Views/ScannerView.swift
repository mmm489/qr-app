import SwiftUI
import SwiftData

struct ScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScannerViewModel()
    @State private var showSavedAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.permissionGranted {
                    if viewModel.isScanning {
                        scannerCamera
                    } else {
                        resultView
                    }
                } else {
                    noPermissionView
                }
            }
            .navigationTitle("Escanear QR")
            .onAppear {
                viewModel.checkCameraPermission()
            }
            .alert("Permiso de Cámara", isPresented: $viewModel.showPermissionAlert) {
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Necesitamos acceso a la cámara para escanear códigos QR. Actívalo en Ajustes.")
            }
            .alert("Guardado", isPresented: $showSavedAlert) {
                Button("OK") {}
            } message: {
                Text("El QR se ha guardado en el historial.")
            }
        }
    }

    // MARK: - Subviews

    private var scannerCamera: some View {
        ZStack {
            QRScannerView { code in
                viewModel.onCodeScanned(code)
            }
            .ignoresSafeArea()

            // Marco de guía
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.7), lineWidth: 3)
                .frame(width: 250, height: 250)
                .shadow(radius: 10)

            VStack {
                Spacer()
                Text("Apunta al código QR")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 60)
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Image(systemName: viewModel.detectedContentType.icon)
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("QR Detectado")
                .font(.title2.bold())

            Text(viewModel.detectedContentType.rawValue)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            GroupBox {
                Text(viewModel.scannedCode ?? "")
                    .font(.body)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)

            // Botones de acción
            VStack(spacing: 12) {
                if viewModel.detectedContentType == .url {
                    Button {
                        viewModel.openURL()
                    } label: {
                        Label("Abrir en navegador", systemImage: "safari")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

                HStack(spacing: 12) {
                    Button {
                        viewModel.copyToClipboard()
                    } label: {
                        Label("Copiar", systemImage: "doc.on.doc")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        saveToHistory()
                    } label: {
                        Label("Guardar", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button {
                viewModel.restartScanning()
            } label: {
                Label("Escanear otro", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(.top, 40)
    }

    private var noPermissionView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Acceso a la cámara necesario")
                .font(.title3.bold())
            Text("Permite el acceso en Ajustes para escanear códigos QR.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Abrir Ajustes") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // MARK: - Actions

    private func saveToHistory() {
        guard let code = viewModel.scannedCode else { return }
        let item = QRItem(
            content: code,
            source: .scanned,
            contentType: viewModel.detectedContentType
        )
        modelContext.insert(item)
        showSavedAlert = true
    }
}

#Preview {
    ScannerView()
        .modelContainer(for: QRItem.self, inMemory: true)
}
