import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                // API Key
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
                    Text("Claude API")
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

                // Notifications
                Section {
                    Toggle(isOn: Binding(
                        get: { viewModel.settings.notificationsEnabled },
                        set: { _ in viewModel.toggleNotifications() }
                    )) {
                        Text("Enable")
                            .font(.system(size: 14))
                    }
                } header: {
                    Text("Notifications")
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
