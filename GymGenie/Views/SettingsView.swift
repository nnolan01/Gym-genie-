import SwiftUI

struct SettingsView: View {
    @State private var apiKey = AppConstants.openAIAPIKey
    var body: some View {
        NavigationView {
            Form {
                Section("AI Configuration") {
                    SecureField("OpenAI API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text("Your API key is used locally to generate workouts from shared content. We recommend rotating keys regularly.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Section("How to Use") {
                    VStack(alignment: .leading, spacing: 10) {
                        StepItem(number: 1, text: "Go to Instagram, TikTok, YouTube, or any app.")
                        StepItem(number: 2, text: "Tap the Share button on any video, article, or link.")
                        StepItem(number: 3, text: "Select 'GymGenie' from the share sheet.")
                        StepItem(number: 4, text: "Open GymGenie, tap 'Build' on the pending item.")
                        StepItem(number: 5, text: "Get a custom gym program instantly.")
                    }
                    .padding(.vertical, 4)
                }
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 (TestFlight)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct StepItem: View {
    let number: Int
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 22, height: 22)
                .background(Color.orange)
                .foregroundColor(.white)
                .clipShape(Circle())
            Text(text)
                .font(.body)
            Spacer()
        }
    }
}
