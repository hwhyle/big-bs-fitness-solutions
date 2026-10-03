import Foundation
import SwiftData

enum ExerciseCatalog {
    @MainActor
    static func seedIfNeeded(in context: ModelContext) {
        do {
            let templateCount = try context.fetchCount(FetchDescriptor<ExerciseTemplate>())
            if templateCount == 0 {
                for seed in seeds {
                    context.insert(seed.makeTemplate())
                }
            }

            let plans = try context.fetch(FetchDescriptor<WeekdayPlan>())
            let existing = Set(plans.map(\.weekday))
            for weekday in 1...7 where !existing.contains(weekday) {
                context.insert(WeekdayPlan(weekday: weekday))
            }
            try context.save()
        } catch {
            assertionFailure("Could not seed fitness catalog: \(error)")
        }
    }

    static func symbol(for muscleGroup: String) -> String {
        switch muscleGroup {
        case "Chest": "figure.strengthtraining.traditional"
        case "Back": "arrow.down.to.line"
        case "Shoulders": "figure.arms.open"
        case "Biceps", "Triceps": "dumbbell.fill"
        case "Quads", "Hamstrings", "Glutes", "Calves": "figure.walk"
        case "Cardio": "heart.fill"
        case "Full body": "flame.fill"
        default: "dumbbell.fill"
        }
    }

    private struct Seed {
        let name: String
        let equipment: String
        let muscleGroup: String
        let kinds: [WorkoutKind]
        let summary: String

        func makeTemplate() -> ExerciseTemplate {
            ExerciseTemplate(
                name: name,
                equipment: equipment,
                muscleGroup: muscleGroup,
                kinds: kinds,
                summary: summary,
                systemImage: ExerciseCatalog.symbol(for: muscleGroup)
            )
        }
    }

    private static let seeds: [Seed] = [
        Seed(name: "Dip Machine", equipment: "Machine", muscleGroup: "Triceps", kinds: [.push], summary: "Assisted or plate-loaded dips for triceps and lower chest."),
        Seed(name: "Parallel Bar Dips", equipment: "Bodyweight", muscleGroup: "Triceps", kinds: [.push], summary: "Bodyweight dips on parallel bars."),
        Seed(name: "Barbell Bench Press", equipment: "Barbell", muscleGroup: "Chest", kinds: [.push, .fullBody], summary: "Flat bench press, the classic horizontal push."),
        Seed(name: "Incline Dumbbell Press", equipment: "Dumbbell", muscleGroup: "Chest", kinds: [.push], summary: "Incline press to bias the upper chest."),
        Seed(name: "Machine Chest Press", equipment: "Machine", muscleGroup: "Chest", kinds: [.push], summary: "Seated chest press with a fixed path."),
        Seed(name: "Pec Deck", equipment: "Machine", muscleGroup: "Chest", kinds: [.push], summary: "Fly machine for chest isolation."),
        Seed(name: "Cable Fly", equipment: "Cable", muscleGroup: "Chest", kinds: [.push], summary: "Standing cable fly through a full stretch."),
        Seed(name: "Overhead Press", equipment: "Barbell", muscleGroup: "Shoulders", kinds: [.push, .fullBody], summary: "Strict standing or seated barbell press."),
        Seed(name: "Shoulder Press Machine", equipment: "Machine", muscleGroup: "Shoulders", kinds: [.push], summary: "Seated overhead press machine."),
        Seed(name: "Lateral Raise", equipment: "Dumbbell", muscleGroup: "Shoulders", kinds: [.push], summary: "Side raises for the medial delts."),
        Seed(name: "Triceps Pushdown", equipment: "Cable", muscleGroup: "Triceps", kinds: [.push], summary: "Cable pressdown with a bar or rope."),
        Seed(name: "Overhead Triceps Extension", equipment: "Cable", muscleGroup: "Triceps", kinds: [.push], summary: "Overhead cable extension for the long head."),
        Seed(name: "Close-Grip Bench Press", equipment: "Barbell", muscleGroup: "Triceps", kinds: [.push], summary: "Narrow-grip bench press."),
        Seed(name: "Push-Up", equipment: "Bodyweight", muscleGroup: "Chest", kinds: [.push, .hiit], summary: "Floor push-ups. Use weight 0, or add a plate."),

        Seed(name: "Lat Pulldown", equipment: "Cable", muscleGroup: "Back", kinds: [.pull], summary: "Wide or neutral-grip pulldown."),
        Seed(name: "Seated Cable Row", equipment: "Cable", muscleGroup: "Back", kinds: [.pull], summary: "Horizontal row for mid-back thickness."),
        Seed(name: "Barbell Row", equipment: "Barbell", muscleGroup: "Back", kinds: [.pull, .fullBody], summary: "Bent-over barbell row."),
        Seed(name: "Chest-Supported Row", equipment: "Machine", muscleGroup: "Back", kinds: [.pull], summary: "Supported row that spares the lower back."),
        Seed(name: "One-Arm Dumbbell Row", equipment: "Dumbbell", muscleGroup: "Back", kinds: [.pull], summary: "Single-arm row from a bench."),
        Seed(name: "Pull-Up", equipment: "Bodyweight", muscleGroup: "Back", kinds: [.pull], summary: "Overhand pull-ups. Log added weight, or 0 for bodyweight."),
        Seed(name: "Assisted Pull-Up", equipment: "Machine", muscleGroup: "Back", kinds: [.pull], summary: "Counterweight pull-up machine."),
        Seed(name: "Face Pull", equipment: "Cable", muscleGroup: "Shoulders", kinds: [.pull], summary: "Rope face pull for rear delts and upper back."),
        Seed(name: "Rear Delt Fly", equipment: "Machine", muscleGroup: "Shoulders", kinds: [.pull], summary: "Reverse pec deck."),
        Seed(name: "Straight-Arm Pulldown", equipment: "Cable", muscleGroup: "Back", kinds: [.pull], summary: "Lat isolation with straight arms."),
        Seed(name: "Barbell Curl", equipment: "Barbell", muscleGroup: "Biceps", kinds: [.pull], summary: "Standing barbell curl."),
        Seed(name: "Hammer Curl", equipment: "Dumbbell", muscleGroup: "Biceps", kinds: [.pull], summary: "Neutral-grip dumbbell curl."),
        Seed(name: "Preacher Curl", equipment: "Machine", muscleGroup: "Biceps", kinds: [.pull], summary: "Supported preacher curl."),

        Seed(name: "Barbell Back Squat", equipment: "Barbell", muscleGroup: "Quads", kinds: [.legs, .fullBody], summary: "High-bar or low-bar back squat."),
        Seed(name: "Leg Press", equipment: "Machine", muscleGroup: "Quads", kinds: [.legs], summary: "Sled or plate-loaded leg press."),
        Seed(name: "Hack Squat", equipment: "Machine", muscleGroup: "Quads", kinds: [.legs], summary: "Hack squat machine."),
        Seed(name: "Goblet Squat", equipment: "Dumbbell", muscleGroup: "Quads", kinds: [.legs, .fullBody], summary: "Front-loaded squat held at the chest."),
        Seed(name: "Walking Lunge", equipment: "Dumbbell", muscleGroup: "Quads", kinds: [.legs], summary: "Alternating walking lunges."),
        Seed(name: "Bulgarian Split Squat", equipment: "Dumbbell", muscleGroup: "Quads", kinds: [.legs], summary: "Rear-foot-elevated split squat."),
        Seed(name: "Leg Extension", equipment: "Machine", muscleGroup: "Quads", kinds: [.legs], summary: "Seated knee extension."),
        Seed(name: "Romanian Deadlift", equipment: "Barbell", muscleGroup: "Hamstrings", kinds: [.legs, .pull], summary: "Hip hinge for hamstrings and glutes."),
        Seed(name: "Lying Leg Curl", equipment: "Machine", muscleGroup: "Hamstrings", kinds: [.legs], summary: "Prone leg curl."),
        Seed(name: "Seated Leg Curl", equipment: "Machine", muscleGroup: "Hamstrings", kinds: [.legs], summary: "Seated hamstring curl."),
        Seed(name: "Hip Thrust", equipment: "Barbell", muscleGroup: "Glutes", kinds: [.legs], summary: "Barbell hip thrust."),
        Seed(name: "Calf Raise Machine", equipment: "Machine", muscleGroup: "Calves", kinds: [.legs], summary: "Standing or seated calf raise."),

        Seed(name: "Conventional Deadlift", equipment: "Barbell", muscleGroup: "Back", kinds: [.fullBody, .pull, .legs], summary: "Full deadlift from the floor."),
        Seed(name: "Kettlebell Swing", equipment: "Kettlebell", muscleGroup: "Glutes", kinds: [.hiit, .fullBody, .cardio], summary: "Hip-hinge swings for power and conditioning."),
        Seed(name: "Thruster", equipment: "Barbell", muscleGroup: "Full body", kinds: [.hiit, .fullBody], summary: "Front squat into a push press."),
        Seed(name: "Farmer Carry", equipment: "Dumbbell", muscleGroup: "Full body", kinds: [.fullBody], summary: "Heavy carry for grip, core, and posture."),
        Seed(name: "Clean and Press", equipment: "Barbell", muscleGroup: "Full body", kinds: [.fullBody, .hiit], summary: "Power clean into an overhead press."),

        Seed(name: "Assault Bike", equipment: "Machine", muscleGroup: "Cardio", kinds: [.hiit, .cardio], summary: "Air bike for hard intervals. Weight can stay 0."),
        Seed(name: "Rowing Machine", equipment: "Machine", muscleGroup: "Cardio", kinds: [.hiit, .cardio, .pull], summary: "Erg intervals or a steady row."),
        Seed(name: "Treadmill", equipment: "Machine", muscleGroup: "Cardio", kinds: [.cardio], summary: "Run, jog, or incline walk."),
        Seed(name: "Stationary Bike", equipment: "Machine", muscleGroup: "Cardio", kinds: [.cardio], summary: "Upright or recumbent bike."),
        Seed(name: "Elliptical", equipment: "Machine", muscleGroup: "Cardio", kinds: [.cardio], summary: "Low-impact steady cardio."),
        Seed(name: "Stair Climber", equipment: "Machine", muscleGroup: "Cardio", kinds: [.cardio, .legs], summary: "Step mill or stair climber."),
        Seed(name: "Jump Rope", equipment: "Bodyweight", muscleGroup: "Cardio", kinds: [.hiit, .cardio], summary: "Speed-rope intervals."),
        Seed(name: "Battle Ropes", equipment: "Rope", muscleGroup: "Cardio", kinds: [.hiit], summary: "Alternating rope waves."),
        Seed(name: "Box Jump", equipment: "Bodyweight", muscleGroup: "Quads", kinds: [.hiit, .legs], summary: "Jump onto a plyo box."),
        Seed(name: "Burpee", equipment: "Bodyweight", muscleGroup: "Full body", kinds: [.hiit, .cardio], summary: "Squat thrust with a jump."),
        Seed(name: "Sled Push", equipment: "Sled", muscleGroup: "Quads", kinds: [.hiit, .legs], summary: "Heavy sled drive."),
    ]
}
