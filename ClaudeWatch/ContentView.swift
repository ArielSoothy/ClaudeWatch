import SwiftUI

struct ContentView: View {
    @State private var approvalsVM = ApprovalsViewModel()
    @State private var messagingVM = MessagingViewModel()
    @State private var settingsVM = SettingsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ApprovalsListView(viewModel: approvalsVM)
                .tag(0)

            MessagingView(viewModel: messagingVM)
                .tag(1)

            SettingsView(viewModel: settingsVM)
                .tag(2)
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            Task {
                _ = await NotificationService.requestPermission()
                NotificationService.registerCategories()
            }
        }
    }
}
