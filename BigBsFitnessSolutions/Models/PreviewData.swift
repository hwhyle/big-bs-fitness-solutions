import SwiftData
import SwiftUI

@MainActor
let previewContainer: ModelContainer = {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ExerciseTemplate.self, WeekdayPlan.self, PlannedExercise.self,
        configurations: configuration
    )
    ExerciseCatalog.seedIfNeeded(in: container.mainContext)
    if let tuesday = try? container.mainContext.fetch(FetchDescriptor<WeekdayPlan>()).first(where: { $0.weekday == 3 }) {
        tuesday.kind = .push
    }
    return container
}()
