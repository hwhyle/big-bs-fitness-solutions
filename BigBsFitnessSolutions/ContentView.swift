import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            WorkoutsView()
                .tabItem {
                    Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                }

            ProgressViewScreen()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
}
