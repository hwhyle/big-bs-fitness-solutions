import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Big B Athlete")
                                .font(.title3.bold())
                            Text("Member since 2026")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Goals") {
                    LabeledContent("Primary goal", value: "Build strength")
                    LabeledContent("Weekly target", value: "4 workouts")
                    LabeledContent("Preferred focus", value: "Full body")
                }

                Section("Preferences") {
                    LabeledContent("Units", value: "Imperial")
                    LabeledContent("Reminders", value: "On")
                }

                Section {
                    Button("Edit Profile", role: .none) {}
                    Button("Sign Out", role: .destructive) {}
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
