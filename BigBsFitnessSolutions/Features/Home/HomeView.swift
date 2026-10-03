import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \WeekdayPlan.weekday) private var plans: [WeekdayPlan]
    @Environment(\.modelContext) private var modelContext

    private var today: WeekdayPlan? {
        plans.first { $0.weekday == WeekCalendar.todayWeekday }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Date.now.formatted(date: .complete, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Big B's Fitness Solutions")
                            .font(.largeTitle.bold())
                        Text("Build the week. Run it in order.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let today {
                        todayCard(today)
                    } else {
                        ProgressView("Loading your week")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .task {
                ExerciseCatalog.seedIfNeeded(in: modelContext)
            }
        }
    }

    @ViewBuilder
    private func todayCard(_ plan: WeekdayPlan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(plan.displayName, systemImage: plan.kind.systemImage)
                    .font(.title2.bold())
                    .foregroundStyle(.orange)
                Spacer()
                Text("Today")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.18), in: Capsule())
                    .foregroundStyle(.orange)
            }

            if plan.kind == .rest {
                Text("Rest day. Recovery counts.")
                    .foregroundStyle(.secondary)
            } else if plan.sortedEntries.isEmpty {
                Text("This \(plan.displayName) day does not have machines yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(plan.sortedEntries.enumerated()), id: \.element.entryID) { index, entry in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.caption.bold())
                            .frame(width: 22, height: 22)
                            .background(Color.orange.opacity(0.18), in: Circle())
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.name)
                                .font(.headline)
                            Text(entry.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            NavigationLink {
                DayPlanView(plan: plan)
            } label: {
                Label(plan.kind == .rest ? "Change today" : "Edit today's workout", systemImage: "calendar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    HomeView()
        .modelContainer(previewContainer)
}
