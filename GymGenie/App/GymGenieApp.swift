import SwiftUI

@main
struct GymGenieApp: App {
    @StateObject private var viewModel = WorkoutViewModel()
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            TabView(selection: $viewModel.selectedTab) {
                HomeView().tabItem { Label("Programs", systemImage: "list.bullet.rectangle") }.tag(0)
                WorkoutsView().tabItem { Label("Workouts", systemImage: "figure.run") }.tag(1)
                SettingsView().tabItem { Label("Settings", systemImage: "gear") }.tag(2)
            }
            .environmentObject(viewModel)
            .onOpenURL { url in
                if url.scheme == "gymgenie" && url.host == "shared" {
                    viewModel.refreshPendingItems()
                    viewModel.selectedTab = 0
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active { viewModel.refreshPendingItems() }
            }
        }
    }
}
