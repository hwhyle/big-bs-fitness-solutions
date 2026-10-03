import SwiftData
import SwiftUI

struct ProfileView: View {
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]
    @Query(sort: \WorkoutSession.dayStart, order: .reverse) private var sessions: [WorkoutSession]
    @AppStorage("appearanceChoice") private var appearanceRaw = AppearanceChoice.system.rawValue

    private var trainingDays: Int {
        plans.filter { $0.kind != .rest }.count
    }

    private var streak: Int {
        WorkoutStats.weekStreak(plans: plans, sessions: sessions)
    }

    private var recentFinishes: [WorkoutSession] {
        sessions.filter(\.isComplete).prefix(6).map { $0 }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.orange)
                            .symbolRenderingMode(.hierarchical)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Big B")
                                .font(.title3.bold())
                            Text("\(trainingDays) training days a week")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }

                Section {
                    Picker("Appearance", selection: $appearanceRaw) {
                        ForEach(AppearanceChoice.allCases) { choice in
                            Text(choice.title).tag(choice.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows the iPhone. Light and Dark stay fixed, including the orange accent.")
                }

                Section {
                    LabeledContent("Week streak", value: streak == 1 ? "1 week" : "\(streak) weeks")
                    LabeledContent("All-time weight moved", value: "\(formatPoundsGrouped(WorkoutStats.allTimeWeight(sessions: sessions))) lb")
                    Text("A week counts when every non-rest day that has machines is fully checked off. Weight moved is the sum of the weights on those sets, not weight × reps.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Gratification")
                }

                if !recentFinishes.isEmpty {
                    Section("Recent finishes") {
                        ForEach(recentFinishes) { session in
                            VStack(alignment: .leading, spacing: 3) {
                                Text(session.title)
                                    .font(.headline)
                                Text(session.dayStart.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(formatPoundsGrouped(session.weightMoved)) lb moved")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                Section("Weekly lineup") {
                    if plans.isEmpty {
                        Text("Your week will show up after the schedule loads.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(WeekCalendar.orderedWeekdays, id: \.self) { weekday in
                            if let plan = plans.first(where: { $0.weekday == weekday }) {
                                LabeledContent(WeekCalendar.symbol(for: weekday), value: plan.displayName)
                            }
                        }
                    }
                }

                Section("On this iPhone") {
                    LabeledContent("Units", value: "Pounds")
                    Text("Schedules, set plans, and finished workouts stay on this device. Nothing is uploaded.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(previewContainer)
}
