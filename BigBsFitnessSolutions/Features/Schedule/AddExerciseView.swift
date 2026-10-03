import SwiftData
import SwiftUI

struct AddExerciseView: View {
    @Bindable var plan: WeekdayPlan
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExerciseTemplate.name) private var templates: [ExerciseTemplate]
    @State private var search = ""

    private var pickedIDs: Set<UUID> {
        Set(plan.entries.map(\.templateID))
    }

    private var recommended: [ExerciseTemplate] {
        RecommendationEngine.recommend(
            kind: plan.kind,
            picked: plan.sortedEntries,
            catalog: templates
        )
    }

    private var browse: [ExerciseTemplate] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = templates.filter { $0.supports(plan.kind) }
        guard !query.isEmpty else { return base }
        return base.filter { template in
            template.name.localizedCaseInsensitiveContains(query)
                || template.muscleGroup.localizedCaseInsensitiveContains(query)
                || template.equipment.localizedCaseInsensitiveContains(query)
                || template.summary.localizedCaseInsensitiveContains(query)
        }
    }

    private var trimmedSearch: String {
        search.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasExactMatch: Bool {
        guard !trimmedSearch.isEmpty else { return true }
        return templates.contains { $0.name.compare(trimmedSearch, options: .caseInsensitive) == .orderedSame }
    }

    var body: some View {
        NavigationStack {
            List {
                if trimmedSearch.isEmpty {
                    Section {
                        if recommended.isEmpty {
                            Text("Every matching machine is already on this day.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(recommended) { template in
                                templateRow(template)
                            }
                        }
                    } header: {
                        Text("Recommended")
                    } footer: {
                        Text("Matches \(plan.displayName) and fills muscle groups you have not added yet.")
                    }
                }

                if !trimmedSearch.isEmpty && !hasExactMatch {
                    Section {
                        Button {
                            addCustom(named: trimmedSearch)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Label("Add \"\(trimmedSearch)\"", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                Text("Not in the list. Save it as your own machine.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .tint(.orange)
                    } header: {
                        Text(browse.isEmpty ? "No matches" : "Don't see it?")
                    } footer: {
                        Text("Saves a custom machine on this phone and tags it for \(plan.displayName).")
                    }
                }

                Section {
                    if browse.isEmpty {
                        if trimmedSearch.isEmpty {
                            Text("No machines in the catalog yet.")
                                .foregroundStyle(.secondary)
                        } else if hasExactMatch {
                            Text("No machines match that search.")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Nothing in the catalog matches \(trimmedSearch). Use Add above.")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ForEach(browse) { template in
                            templateRow(template)
                        }
                    }
                } header: {
                    Text(trimmedSearch.isEmpty ? "All \(plan.displayName) machines" : "Search")
                } footer: {
                    if trimmedSearch.isEmpty {
                        Text("Search for a machine. If it isn't listed, you can add it by the name you type.")
                    }
                }
            }
            .searchable(text: $search, prompt: "Search machines")
            .navigationTitle("Add machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func templateRow(_ template: ExerciseTemplate) -> some View {
        let alreadyAdded = pickedIDs.contains(template.catalogID)
        return Button {
            guard !alreadyAdded else { return }
            add(template)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: template.systemImage)
                    .foregroundStyle(.orange)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 3) {
                    Text(template.name)
                        .foregroundStyle(.primary)
                    Text(template.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(template.summary)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                Image(systemName: alreadyAdded ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundStyle(alreadyAdded ? Color.secondary : Color.orange)
            }
        }
        .disabled(alreadyAdded)
    }

    private func add(_ template: ExerciseTemplate) {
        let next = (plan.entries.map(\.sortIndex).max() ?? -1) + 1
        let cardio = template.muscleGroup == "Cardio"
        let entry = PlannedExercise(
            sortIndex: next,
            templateID: template.catalogID,
            name: template.name,
            muscleGroup: template.muscleGroup,
            equipment: template.equipment,
            systemImage: template.systemImage,
            setCount: cardio ? 1 : 3,
            style: cardio ? .same : .progression,
            sameWeight: cardio ? 0 : 50,
            startWeight: cardio ? 0 : 50,
            increment: cardio ? 0 : 10
        )
        entry.plan = plan
        modelContext.insert(entry)
    }

    private func addCustom(named name: String) {
        if let existing = templates.first(where: { $0.name.compare(name, options: .caseInsensitive) == .orderedSame }) {
            add(existing)
            search = ""
            return
        }
        let kind = plan.kind == .rest ? WorkoutKind.custom : plan.kind
        let template = ExerciseTemplate(
            name: name,
            equipment: "Custom",
            muscleGroup: "Custom",
            kinds: [kind],
            summary: "Added by you.",
            systemImage: "plus.circle.fill",
            isUserCreated: true
        )
        modelContext.insert(template)
        add(template)
        search = ""
    }
}
