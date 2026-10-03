import Foundation
import SwiftData

struct LoggedSet: Codable, Equatable, Identifiable {
    var entryID: UUID
    var name: String
    var setIndex: Int
    var weight: Double

    var id: String { "\(entryID.uuidString)#\(setIndex)" }
}

@Model
final class WorkoutSession {
    var sessionID: UUID
    var dayStart: Date
    var weekday: Int
    var kindRaw: String
    var title: String
    var isComplete: Bool
    var completedAt: Date?
    var weightMoved: Double
    var setsJSON: String

    init(dayStart: Date, weekday: Int, kindRaw: String, title: String) {
        self.sessionID = UUID()
        self.dayStart = dayStart
        self.weekday = weekday
        self.kindRaw = kindRaw
        self.title = title
        self.isComplete = false
        self.completedAt = nil
        self.weightMoved = 0
        self.setsJSON = "[]"
    }

    var loggedSets: [LoggedSet] {
        get {
            guard let data = setsJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([LoggedSet].self, from: data) else {
                return []
            }
            return decoded
        }
        set {
            let data = (try? JSONEncoder().encode(newValue)) ?? Data("[]".utf8)
            setsJSON = String(decoding: data, as: UTF8.self)
        }
    }

    /// Keeps checked sets that still exist on the plan. Weights stay as they were when checked.
    /// Returns whether every current set is checked off.
    @discardableResult
    func apply(plan: WeekdayPlan, sets: [LoggedSet]) -> Bool {
        let entries = plan.sortedEntries
        let pruned = sets.filter { set in
            guard let entry = entries.first(where: { $0.entryID == set.entryID }) else { return false }
            return entry.resolvedWeights().indices.contains(set.setIndex)
        }
        loggedSets = pruned
        weightMoved = pruned.reduce(0) { $0 + max(0, $1.weight) }
        kindRaw = plan.kind.rawValue
        title = plan.displayName
        weekday = plan.weekday

        let done = Set(pruned.map(\.id))
        var needed = 0
        var met = 0
        for entry in entries {
            for index in entry.resolvedWeights().indices {
                needed += 1
                if done.contains("\(entry.entryID.uuidString)#\(index)") {
                    met += 1
                }
            }
        }
        let complete = needed > 0 && met == needed
        if complete {
            if completedAt == nil {
                completedAt = Date()
            }
            isComplete = true
        } else {
            isComplete = false
            completedAt = nil
        }
        return complete
    }

    func containsSet(entryID: UUID, setIndex: Int) -> Bool {
        loggedSets.contains { $0.entryID == entryID && $0.setIndex == setIndex }
    }
}

enum WorkoutStats {
    static func allTimeWeight(sessions: [WorkoutSession]) -> Double {
        sessions.reduce(0) { partial, session in
            partial + (session.isComplete ? session.weightMoved : 0)
        }
    }

    static func requiredWeekdays(plans: [WeekdayPlan]) -> [Int] {
        plans
            .filter { $0.kind.buildsWorkout && !$0.entries.isEmpty }
            .map(\.weekday)
            .sorted()
    }

    static func isWeekComplete(reference: Date, plans: [WeekdayPlan], sessions: [WorkoutSession], now: Date = Date()) -> Bool {
        let required = requiredWeekdays(plans: plans)
        guard !required.isEmpty else { return false }
        let calendar = WeekCalendar.calendar
        let today = calendar.startOfDay(for: now)
        for weekday in required {
            let date = calendar.startOfDay(for: WeekCalendar.date(for: weekday, reference: reference))
            if date > today { return false }
            let hit = sessions.contains { session in
                session.isComplete && calendar.isDate(session.dayStart, inSameDayAs: date)
            }
            if !hit { return false }
        }
        return true
    }

    /// Consecutive weeks, ending at the latest fully finished week, where every
    /// non-rest day that has machines was checked off. Uses the current weekly plan.
    static func weekStreak(plans: [WeekdayPlan], sessions: [WorkoutSession], now: Date = Date()) -> Int {
        guard !requiredWeekdays(plans: plans).isEmpty else { return 0 }
        let calendar = WeekCalendar.calendar
        var reference = now
        if !isWeekComplete(reference: reference, plans: plans, sessions: sessions, now: now) {
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: reference) else { return 0 }
            reference = previous
        }
        var streak = 0
        while streak < 520 && isWeekComplete(reference: reference, plans: plans, sessions: sessions, now: now) {
            streak += 1
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: reference) else { break }
            reference = previous
        }
        return streak
    }

    static func celebrationTitle(streak: Int, closedTheWeek: Bool) -> String {
        if closedTheWeek && streak >= 4 && streak % 4 == 0 {
            return "\(streak) weeks in a row"
        }
        if closedTheWeek {
            return "Week complete"
        }
        return "Workout complete"
    }

    static func celebrationDetail(streak: Int, closedTheWeek: Bool) -> String {
        if streak >= 4 && streak % 4 == 0 {
            return "That's \(streak) weeks straight of every planned training day. A month of showing up."
        }
        if streak == 4 {
            return "Four weeks in a row. That's the milestone."
        }
        if closedTheWeek && streak > 1 {
            return "\(streak) weeks in a row. Every training day, checked off."
        }
        if closedTheWeek && streak == 1 {
            return "First full week on the board. Do it again next week."
        }
        if streak > 1 {
            return "You're on a \(streak)-week streak. Finish the rest of this week's training days to keep it."
        }
        if streak == 1 {
            return "Last week was a full week. Close this one out the same way."
        }
        return "Check off every training day this week to start a streak."
    }
}
