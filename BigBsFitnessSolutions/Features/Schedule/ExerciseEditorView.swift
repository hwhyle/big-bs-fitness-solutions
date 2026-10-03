import SwiftData
import SwiftUI

struct ExerciseEditorView: View {
    @Bindable var exercise: PlannedExercise
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            Section {
                LabeledContent("Equipment", value: exercise.equipment)
                LabeledContent("Muscle", value: exercise.muscleGroup)
            }

            Section {
                Picker("Weight style", selection: styleBinding) {
                    ForEach(WeightStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)

                Text(exercise.style.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Stepper(value: $exercise.setCount, in: 1...12) {
                    LabeledContent("Sets", value: "\(exercise.setCount)")
                }
                .onChange(of: exercise.setCount) { _, _ in
                    if exercise.style == .custom {
                        exercise.customWeights = exercise.resolvedWeights()
                    }
                }

                switch exercise.style {
                case .same:
                    weightRow("Weight", value: $exercise.sameWeight)
                case .progression:
                    weightRow("Start", value: $exercise.startWeight)
                    weightRow("Add each set", value: $exercise.increment)
                case .custom:
                    ForEach(exercise.resolvedWeights().indices, id: \.self) { index in
                        weightRow(
                            "Set \(index + 1)",
                            value: Binding(
                                get: {
                                    let weights = exercise.resolvedWeights()
                                    return weights.indices.contains(index) ? weights[index] : 0
                                },
                                set: { exercise.setCustomWeight($0, at: index) }
                            )
                        )
                    }
                }
            } header: {
                Text("Plan")
            }

            Section("Result") {
                ForEach(Array(exercise.resolvedWeights().enumerated()), id: \.offset) { index, weight in
                    LabeledContent("Set \(index + 1)", value: "\(formatPounds(weight)) lb")
                }
            }

            Section {
                Button(role: .destructive) {
                    modelContext.delete(exercise)
                    dismiss()
                } label: {
                    Label("Remove machine", systemImage: "trash")
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: exercise.styleRaw) { _, newValue in
            if newValue == WeightStyle.custom.rawValue && exercise.customWeights.isEmpty {
                exercise.customWeights = exercise.resolvedWeights()
            }
        }
    }

    private var styleBinding: Binding<WeightStyle> {
        Binding(
            get: { exercise.style },
            set: { newStyle in
                if newStyle == .custom {
                    exercise.customWeights = exercise.resolvedWeights()
                }
                exercise.style = newStyle
            }
        )
    }

    private func weightRow(_ title: String, value: Binding<Double>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField("lb", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 72)
            Stepper("", value: value, in: 0...2000, step: 5)
                .labelsHidden()
            Text("lb")
                .foregroundStyle(.secondary)
        }
    }
}
