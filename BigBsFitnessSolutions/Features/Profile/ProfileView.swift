import SwiftData
import SwiftUI

struct ProfileView: View {
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]

    private var trainingDays: Int {
        plans.filter { $0.kind != .rest }.count
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(.orange)
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
                    Text("Schedules and set plans stay on this device. Nothing is uploaded.")
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
