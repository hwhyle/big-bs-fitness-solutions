import SwiftData
import SwiftUI

struct DayPlanView: View {
    @Bindable var plan: WeekdayPlan
    @Environment(\.modelContext) private var modelContext
    @State private var showingAdd = false

    private var date: Date {
        WeekCalendar.date(for: plan.weekday)
    }

    var body: some View {
        List {
            Section {
                Picker("Workout type", selection: kindBinding) {
                    ForEach(WorkoutKind.allCases) { kind in
                        Label(kind.rawValue, systemImage: kind.systemImage)
                            .tag(kind)
                    }
                }
                .pickerStyle(.menu)

                if plan.kind == .custom {
                    TextField("Custom name", text: $plan.customTitle)
                }
            } footer: {
                Text(date.formatted(date: .complete, time: .omitted))
            }

            if plan.kind == .rest {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Rest day", systemImage: "moon.zzz.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        Text("No machines on a rest day. Switch the type if you still want to train. Anything you already added is kept.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            } else {
                Section {
                    if plan.sortedEntries.isEmpty {
                        ContentUnavailableView(
                            "No machines yet",
                            systemImage: "plus.circle",
                            description: Text("Add machines in the order you want to do them.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(plan.sortedEntries) { entry in
                            NavigationLink {
                                ExerciseEditorView(exercise: entry)
                            } label: {
                                ExercisePlanRow(exercise: entry)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    modelContext.delete(entry)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    move(entry, direction: -1)
                                } label: {
                                    Label("Up", systemImage: "chevron.up")
                                }
                                .tint(.orange)
                                Button {
                                    move(entry, direction: 1)
                                } label: {
                                    Label("Down", systemImage: "chevron.down")
                                }
                                .tint(.gray)
                            }
                        }
                    }
                } header: {
                    Text("In order")
                } footer: {
                    if !plan.sortedEntries.isEmpty {
                        Text("Swipe right to reorder. Tap a machine to set the weights.")
                    }
                }

                Section {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add machine", systemImage: "plus")
                    }
                    .tint(.orange)
                }
            }
        }
        .navigationTitle(WeekCalendar.symbol(for: plan.weekday))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAdd) {
            AddExerciseView(plan: plan)
        }
    }

    private var kindBinding: Binding<WorkoutKind> {
        Binding(
            get: { plan.kind },
            set: { plan.kind = $0 }
        )
    }

    private func move(_ entry: PlannedExercise, direction: Int) {
        var sorted = plan.sortedEntries
        guard let index = sorted.firstIndex(where: { $0.entryID == entry.entryID }) else { return }
        let target = index + direction
        guard sorted.indices.contains(target) else { return }
        sorted.swapAt(index, target)
        for (offset, item) in sorted.enumerated() {
            item.sortIndex = offset
        }
    }
}

private struct ExercisePlanRow: View {
    let exercise: PlannedExercise

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.systemImage)
                .foregroundStyle(.orange)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                Text(exercise.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(exercise.muscleGroup)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}
