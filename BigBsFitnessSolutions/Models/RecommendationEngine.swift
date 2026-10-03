import Foundation

enum RecommendationEngine {
    /// Rule-based suggestions: match the day's workout type, then prefer muscle
    /// groups that are not already covered by machines in the plan.
    static func recommend(
        kind: WorkoutKind,
        picked: [PlannedExercise],
        catalog: [ExerciseTemplate],
        limit: Int = 8
    ) -> [ExerciseTemplate] {
        let pickedIDs = Set(picked.map(\.templateID))
        var groupCounts: [String: Int] = [:]
        for exercise in picked {
            groupCounts[exercise.muscleGroup, default: 0] += 1
        }

        let matches = catalog.filter { template in
            !pickedIDs.contains(template.catalogID) && template.supports(kind)
        }

        let ranked = matches.sorted { lhs, rhs in
            let leftCount = groupCounts[lhs.muscleGroup, default: 0]
            let rightCount = groupCounts[rhs.muscleGroup, default: 0]
            if leftCount != rightCount {
                return leftCount < rightCount
            }
            let leftPriority = priority(lhs.muscleGroup, kind: kind)
            let rightPriority = priority(rhs.muscleGroup, kind: kind)
            if leftPriority != rightPriority {
                return leftPriority < rightPriority
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return Array(ranked.prefix(limit))
    }

    private static func priority(_ muscle: String, kind: WorkoutKind) -> Int {
        kind.musclePriority.firstIndex(of: muscle) ?? 50
    }
}
