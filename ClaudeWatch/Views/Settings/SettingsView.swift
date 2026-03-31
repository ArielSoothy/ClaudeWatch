import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                // Relay Connection
                Section {
                    if viewModel.hasRelay {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundStyle(Theme.approve)
                            Text("Connected")
                                .font(.system(size: 14))
                        }
                        Button(role: .destructive) {
                            viewModel.deleteRelay()
                        } label: {
                            Label("Disconnect", systemImage: "xmark.circle")
                                .font(.system(size: 14))
                        }
                    } else {
                        TextField("Relay secret", text: $viewModel.relaySecret)
                            .font(.system(size: 13))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button {
                            viewModel.saveRelay()
                        } label: {
                            Label("Connect", systemImage: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 14))
                        }
                        .disabled(viewModel.relaySecret.isEmpty)
                    }
                } header: {
                    Text("Claude Code Relay")
                }

                // API Key (optional — for direct chat)
                Section {
                    if viewModel.hasAPIKey {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundStyle(Theme.approve)
                            Text("API Key Set")
                                .font(.system(size: 14))
                        }
                        Button(role: .destructive) {
                            viewModel.deleteAPIKey()
                        } label: {
                            Label("Remove Key", systemImage: "trash")
                                .font(.system(size: 14))
                        }
                    } else {
                        TextField("sk-ant-...", text: $viewModel.apiKey)
                            .font(.system(size: 13))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button {
                            viewModel.saveAPIKey()
                        } label: {
                            Label("Save Key", systemImage: "key.fill")
                                .font(.system(size: 14))
                        }
                        .disabled(viewModel.apiKey.isEmpty)
                    }
                } header: {
                    Text("Claude API (Optional)")
                }

                // Haptics
                Section {
                    Picker("Intensity", selection: Binding(
                        get: { viewModel.settings.hapticIntensity },
                        set: { viewModel.updateHapticIntensity($0) }
                    )) {
                        ForEach(AppSettings.HapticIntensity.allCases, id: \.self) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    .font(.system(size: 14))
                } header: {
                    Text("Haptics")
                }

                // About
                Section {
                    HStack {
                        Text("Version")
                            .font(.system(size: 13))
                        Spacer()
                        Text("1.0.0")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
