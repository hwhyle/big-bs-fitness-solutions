import SwiftData
import SwiftUI
import UIKit

struct FitnessStatsStrip: View {
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]
    @Query(sort: \WorkoutSession.dayStart) private var sessions: [WorkoutSession]

    private var streak: Int {
        WorkoutStats.weekStreak(plans: plans, sessions: sessions)
    }

    private var allTime: Double {
        WorkoutStats.allTimeWeight(sessions: sessions)
    }

    var body: some View {
        HStack(spacing: 12) {
            statTile(
                systemImage: streak >= 4 ? "flame.fill" : "flame",
                title: "Week streak",
                value: streak == 1 ? "1 week" : "\(streak) weeks",
                caption: streakCaption
            )
            statTile(
                systemImage: "scalemass.fill",
                title: "All time",
                value: "\(formatPoundsGrouped(allTime)) lb",
                caption: "Weight moved"
            )
        }
    }

    private var streakCaption: String {
        if streak == 0 {
            return "Finish every training day"
        }
        if streak >= 4 && streak % 4 == 0 {
            return "Milestone"
        }
        return "In a row"
    }

    private func statTile(systemImage: String, title: String, value: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct TodayWorkoutSection: View {
    @Bindable var plan: WeekdayPlan
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]
    @Query(sort: \WorkoutSession.dayStart) private var sessions: [WorkoutSession]
    @Environment(\.modelContext) private var modelContext
    @State private var celebration: CelebrationPayload?

    private var todaySession: WorkoutSession? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return sessions.first { calendar.isDate($0.dayStart, inSameDayAs: start) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            let entries = plan.sortedEntries
            let totalSets = entries.reduce(0) { $0 + $1.resolvedWeights().count }
            let doneSets = checkedCount(entries: entries)
            let finished = todaySession?.isComplete == true && doneSets == totalSets && totalSets > 0

            HStack {
                Text(finished ? "Finished" : "Check it off")
                    .font(.headline)
                Spacer()
                Text("\(doneSets) of \(totalSets) sets")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.orange)
                    .monospacedDigit()
            }

            ProgressView(value: Double(doneSets), total: Double(max(totalSets, 1)))
                .tint(.orange)

            Text(weightLine(finished: finished))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(entries, id: \.entryID) { entry in
                machineBlock(entry)
            }
        }
        .onAppear {
            guard !plan.sortedEntries.isEmpty, let todaySession else { return }
            todaySession.apply(plan: plan, sets: todaySession.loggedSets)
        }
        .fullScreenCover(item: $celebration) { payload in
            CelebrationView(payload: payload) {
                celebration = nil
            }
        }
    }

    private func weightLine(finished: Bool) -> String {
        let sessionWeight = todaySession?.weightMoved ?? 0
        let amount = "\(formatPoundsGrouped(sessionWeight)) lb moved"
        if finished {
            return "\(amount) today. That's the sum of the weights on the sets you checked, not weight × reps."
        }
        return "\(amount) so far. Each finished set adds its weight. Reps aren't tracked."
    }

    private func machineBlock(_ entry: PlannedExercise) -> some View {
        let weights = entry.resolvedWeights()
        let allOn = !weights.isEmpty && weights.indices.allSatisfy { todaySession?.containsSet(entryID: entry.entryID, setIndex: $0) == true }
        return VStack(alignment: .leading, spacing: 8) {
            Button {
                toggleMachine(entry, allOn: allOn)
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: allOn ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(allOn ? Color.orange : Color.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(entry.summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            ForEach(Array(weights.enumerated()), id: \.offset) { index, plannedWeight in
                let logged = todaySession?.loggedSets.first { $0.entryID == entry.entryID && $0.setIndex == index }
                let done = logged != nil
                let shown = logged?.weight ?? plannedWeight
                Button {
                    toggleSet(entry, index: index, plannedWeight: plannedWeight)
                } label: {
                    HStack {
                        Image(systemName: done ? "checkmark.square.fill" : "square")
                            .foregroundStyle(done ? Color.orange : Color.secondary)
                        Text("Set \(index + 1)")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("\(formatPounds(shown)) lb")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    .font(.subheadline)
                }
                .buttonStyle(.plain)
                .padding(.leading, 34)
            }
        }
        .padding(.vertical, 4)
    }

    private func checkedCount(entries: [PlannedExercise]) -> Int {
        guard let todaySession else { return 0 }
        return entries.reduce(0) { partial, entry in
            partial + entry.resolvedWeights().indices.filter { todaySession.containsSet(entryID: entry.entryID, setIndex: $0) }.count
        }
    }

    private func ensureSession() -> WorkoutSession {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        if let todaySession {
            return todaySession
        }
        let fetched = (try? modelContext.fetch(FetchDescriptor<WorkoutSession>())) ?? []
        if let existing = fetched.first(where: { calendar.isDate($0.dayStart, inSameDayAs: start) }) {
            return existing
        }
        let created = WorkoutSession(
            dayStart: start,
            weekday: plan.weekday,
            kindRaw: plan.kind.rawValue,
            title: plan.displayName
        )
        modelContext.insert(created)
        return created
    }

    private func toggleSet(_ entry: PlannedExercise, index: Int, plannedWeight: Double) {
        let session = ensureSession()
        var sets = session.loggedSets
        if let existing = sets.firstIndex(where: { $0.entryID == entry.entryID && $0.setIndex == index }) {
            sets.remove(at: existing)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            sets.append(LoggedSet(entryID: entry.entryID, name: entry.name, setIndex: index, weight: plannedWeight))
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        commit(session: session, sets: sets)
    }

    private func toggleMachine(_ entry: PlannedExercise, allOn: Bool) {
        let session = ensureSession()
        var sets = session.loggedSets.filter { $0.entryID != entry.entryID }
        if !allOn {
            for (index, weight) in entry.resolvedWeights().enumerated() {
                sets.append(LoggedSet(entryID: entry.entryID, name: entry.name, setIndex: index, weight: weight))
            }
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        commit(session: session, sets: sets)
    }

    private func commit(session: WorkoutSession, sets: [LoggedSet]) {
        let wasComplete = session.isComplete
        let nowComplete = session.apply(plan: plan, sets: sets)
        if !wasComplete && nowComplete {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let included = sessions.contains(where: { $0.sessionID == session.sessionID }) ? sessions : sessions + [session]
            let streak = WorkoutStats.weekStreak(plans: plans, sessions: included)
            let closed = WorkoutStats.isWeekComplete(reference: Date(), plans: plans, sessions: included)
            celebration = CelebrationPayload(
                workoutTitle: plan.displayName,
                sessionWeight: session.weightMoved,
                allTimeWeight: WorkoutStats.allTimeWeight(sessions: included),
                streak: streak,
                closedTheWeek: closed
            )
        }
    }
}
