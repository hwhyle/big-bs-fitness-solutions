import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome to")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Big B's Fitness Solutions")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                        Text("Train hard. Track progress. Stay consistent.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Workouts", value: "12", subtitle: "This week", icon: "flame.fill")
                        StatCard(title: "Minutes", value: "248", subtitle: "Active time", icon: "clock.fill")
                        StatCard(title: "Streak", value: "5", subtitle: "Days", icon: "bolt.fill")
                        StatCard(title: "Calories", value: "1.8k", subtitle: "Burned", icon: "heart.fill")
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Start")
                            .font(.headline)
                        NavigationLink {
                            WorkoutsView()
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Browse Workouts")
                                        .font(.headline)
                                    Text("Pick a session and get moving")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .background(Color(.systemGroupedBackground))
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
