import SwiftData
import SwiftUI

@main
struct BigBsFitnessSolutionsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ExerciseTemplate.self, WeekdayPlan.self, PlannedExercise.self])
    }
}
