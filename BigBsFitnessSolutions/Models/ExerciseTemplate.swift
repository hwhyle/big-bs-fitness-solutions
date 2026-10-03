import Foundation
import SwiftData

@Model
final class ExerciseTemplate {
    var catalogID: UUID
    var name: String
    var equipment: String
    var muscleGroup: String
    var kindsRaw: String
    var summary: String
    var systemImage: String
    var isUserCreated: Bool

    init(
        name: String,
        equipment: String,
        muscleGroup: String,
        kinds: [WorkoutKind],
        summary: String,
        systemImage: String,
        isUserCreated: Bool = false
    ) {
        self.catalogID = UUID()
        self.name = name
        self.equipment = equipment
        self.muscleGroup = muscleGroup
        self.kindsRaw = kinds.map(\.rawValue).joined(separator: ",")
        self.summary = summary
        self.systemImage = systemImage
        self.isUserCreated = isUserCreated
    }

    var kinds: [WorkoutKind] {
        kindsRaw.split(separator: ",").compactMap { WorkoutKind(rawValue: String($0)) }
    }

    func supports(_ kind: WorkoutKind) -> Bool {
        switch kind {
        case .custom:
            return true
        case .rest:
            return false
        default:
            return kinds.contains(kind)
        }
    }

    var subtitle: String {
        "\(equipment) · \(muscleGroup)"
    }
}
