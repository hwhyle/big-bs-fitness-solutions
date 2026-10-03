import SwiftData
import SwiftUI

struct ScheduleView: View {
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Repeats every week")
                            .font(.subheadline.weight(.semibold))
                        Text("Assign a workout type to each day, then build the machines in order.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("This week") {
                    ForEach(WeekCalendar.orderedWeekdays, id: \.self) { weekday in
                        if let plan = plans.first(where: { $0.weekday == weekday }) {
                            NavigationLink {
                                DayPlanView(plan: plan)
                            } label: {
                                ScheduleDayRow(plan: plan)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .task {
                ExerciseCatalog.seedIfNeeded(in: modelContext)
            }
        }
    }
}

private struct ScheduleDayRow: View {
    let plan: WeekdayPlan

    private var isToday: Bool {
        plan.weekday == WeekCalendar.todayWeekday
    }

    private var date: Date {
        WeekCalendar.date(for: plan.weekday)
    }

    private var detail: String {
        if plan.kind == .rest {
            return "Recovery day"
        }
        let count = plan.entries.count
        if count == 0 {
            return "No machines yet"
        }
        return count == 1 ? "1 machine" : "\(count) machines"
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(WeekCalendar.symbol(for: plan.weekday, short: true).uppercased())
                    .font(.caption2.weight(.bold))
                Text(date.formatted(.dateTime.day()))
                    .font(.title3.bold())
            }
            .frame(width: 44)
            .foregroundStyle(isToday ? Color.orange : Color.primary)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: plan.kind.systemImage)
                        .foregroundStyle(.orange)
                    Text(plan.displayName)
                        .font(.headline)
                }
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            if isToday {
                Text("Today")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.18), in: Capsule())
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ScheduleView()
        .modelContainer(previewContainer)
}
