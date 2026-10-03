import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("appearanceChoice") private var appearanceRaw = AppearanceChoice.system.rawValue

    private var appearance: AppearanceChoice {
        AppearanceChoice(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.orange)
        .preferredColorScheme(appearance.colorScheme)
        .task {
            ExerciseCatalog.seedIfNeeded(in: modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
