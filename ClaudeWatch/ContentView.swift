import SwiftUI

struct ContentView: View {
    @StateObject private var approvalsVM = ApprovalsViewModel()
    @StateObject private var messagingVM = MessagingViewModel()
    @StateObject private var settingsVM = SettingsViewModel()

    var body: some View {
        TabView {
            ApprovalsListView(viewModel: approvalsVM)
            MessagingView(viewModel: messagingVM)
            SettingsView(viewModel: settingsVM)
        }
        .tabViewStyle(.verticalPage)
    }
}
