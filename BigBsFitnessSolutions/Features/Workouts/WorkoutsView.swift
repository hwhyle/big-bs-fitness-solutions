import SwiftUI

struct WorkoutsView: View {
    private let workouts = Workout.samples

    var body: some View {
        NavigationStack {
            List(workouts) { workout in
                NavigationLink {
                    WorkoutDetailView(workout: workout)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: workout.systemImage)
                            .font(.title2)
                            .foregroundStyle(.orange)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.durationMinutes) min · \(workout.difficulty.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Workouts")
        }
    }
}

private struct WorkoutDetailView: View {
    let workout: Workout

    var body: some View {
        List {
            Section {
                LabeledContent("Duration", value: "\(workout.durationMinutes) minutes")
                LabeledContent("Difficulty", value: workout.difficulty.rawValue)
                LabeledContent("Focus", value: workout.focus)
            }
            Section("About") {
                Text(workout.description)
            }
            Section {
                Button {
                    // Placeholder for start workout action
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    WorkoutsView()
}
