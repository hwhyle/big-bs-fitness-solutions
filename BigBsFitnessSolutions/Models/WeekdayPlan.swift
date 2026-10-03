import Foundation
import SwiftData

@Model
final class WeekdayPlan {
    var weekday: Int
    var kindRaw: String
    var customTitle: String
    @Relationship(deleteRule: .cascade, inverse: \PlannedExercise.plan)
    var entries: [PlannedExercise]

    init(weekday: Int, kind: WorkoutKind = .rest, customTitle: String = "") {
        self.weekday = weekday
        self.kindRaw = kind.rawValue
        self.customTitle = customTitle
        self.entries = []
    }

    var kind: WorkoutKind {
        get { WorkoutKind(rawValue: kindRaw) ?? .rest }
        set { kindRaw = newValue.rawValue }
    }

    var sortedEntries: [PlannedExercise] {
        entries.sorted { lhs, rhs in
            if lhs.sortIndex == rhs.sortIndex {
                return lhs.name < rhs.name
            }
            return lhs.sortIndex < rhs.sortIndex
        }
    }

    var displayName: String {
        if kind == .custom {
            let trimmed = customTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Custom" : trimmed
        }
        return kind.rawValue
    }
}
