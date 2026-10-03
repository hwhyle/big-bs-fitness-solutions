import Foundation

enum WorkoutKind: String, Codable, CaseIterable, Identifiable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Legs"
    case hiit = "HIIT"
    case cardio = "Cardio"
    case fullBody = "Full Body"
    case rest = "Rest"
    case custom = "Custom"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .push: "figure.strengthtraining.traditional"
        case .pull: "arrow.down.to.line"
        case .legs: "figure.walk"
        case .hiit: "flame.fill"
        case .cardio: "heart.fill"
        case .fullBody: "figure.mixed.cardio"
        case .rest: "moon.zzz.fill"
        case .custom: "slider.horizontal.3"
        }
    }

    var buildsWorkout: Bool { self != .rest }

    /// Muscle groups to surface first when nothing is picked yet.
    var musclePriority: [String] {
        switch self {
        case .push: ["Chest", "Shoulders", "Triceps"]
        case .pull: ["Back", "Biceps", "Shoulders"]
        case .legs: ["Quads", "Hamstrings", "Glutes", "Calves"]
        case .hiit: ["Full body", "Cardio", "Quads", "Glutes"]
        case .cardio: ["Cardio", "Full body"]
        case .fullBody: ["Full body", "Quads", "Back", "Chest", "Glutes"]
        case .custom: ["Chest", "Back", "Quads", "Shoulders", "Hamstrings", "Glutes", "Biceps", "Triceps", "Calves", "Cardio", "Full body"]
        case .rest: []
        }
    }
}

enum WeightStyle: String, Codable, CaseIterable, Identifiable {
    case same = "Same"
    case custom = "Custom"
    case progression = "Progression"

    var id: String { rawValue }

    var detail: String {
        switch self {
        case .same: "One weight for every set"
        case .custom: "Type a weight for each set"
        case .progression: "Start weight, then add each set"
        }
    }
}

func formatPounds(_ value: Double) -> String {
    let tenths = (value * 10).rounded() / 10
    if tenths == tenths.rounded() {
        return String(Int(tenths))
    }
    return String(format: "%.1f", tenths)
}

enum WeekCalendar {
    static var calendar: Calendar { Calendar.current }

    static var orderedWeekdays: [Int] {
        let first = calendar.firstWeekday
        return (0..<7).map { ((first - 1 + $0) % 7) + 1 }
    }

    static var todayWeekday: Int {
        calendar.component(.weekday, from: Date())
    }

    static func date(for weekday: Int, reference: Date = Date()) -> Date {
        let start = calendar.dateInterval(of: .weekOfYear, for: reference)?.start ?? reference
        let first = calendar.firstWeekday
        var offset = weekday - first
        if offset < 0 { offset += 7 }
        let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: start)) ?? reference
        return day
    }

    static func symbol(for weekday: Int, short: Bool = false) -> String {
        let symbols = short ? calendar.shortWeekdaySymbols : calendar.weekdaySymbols
        let index = weekday - 1
        guard symbols.indices.contains(index) else { return "" }
        return symbols[index]
    }
}
