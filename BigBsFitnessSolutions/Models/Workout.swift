import Foundation

struct Workout: Identifiable, Hashable {
    enum Difficulty: String, Hashable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
    }

    let id: UUID
    let name: String
    let durationMinutes: Int
    let difficulty: Difficulty
    let focus: String
    let description: String
    let systemImage: String

    static let samples: [Workout] = [
        Workout(
            id: UUID(),
            name: "Full Body Power",
            durationMinutes: 45,
            difficulty: .intermediate,
            focus: "Strength",
            description: "Compound lifts and core work to build total-body strength.",
            systemImage: "dumbbell.fill"
        ),
        Workout(
            id: UUID(),
            name: "HIIT Burn",
            durationMinutes: 25,
            difficulty: .advanced,
            focus: "Cardio",
            description: "Short intervals with maximum effort and active recovery.",
            systemImage: "flame.fill"
        ),
        Workout(
            id: UUID(),
            name: "Mobility Flow",
            durationMinutes: 30,
            difficulty: .beginner,
            focus: "Flexibility",
            description: "Gentle mobility drills to improve range of motion and recovery.",
            systemImage: "figure.flexibility"
        ),
        Workout(
            id: UUID(),
            name: "Push Day",
            durationMinutes: 40,
            difficulty: .intermediate,
            focus: "Upper body",
            description: "Chest, shoulders, and triceps with progressive overload.",
            systemImage: "figure.arms.open"
        ),
        Workout(
            id: UUID(),
            name: "Core Crusher",
            durationMinutes: 20,
            difficulty: .beginner,
            focus: "Core",
            description: "Planks, twists, and anti-rotation moves for a stronger midsection.",
            systemImage: "circle.grid.cross.fill"
        ),
    ]
}
