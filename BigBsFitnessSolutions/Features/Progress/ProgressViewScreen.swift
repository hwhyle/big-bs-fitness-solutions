import SwiftUI

struct ProgressViewScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Your progress will show up here once you start logging workouts.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week")
                            .font(.headline)
                        ForEach(weeklyStats, id: \.day) { stat in
                            HStack {
                                Text(stat.day)
                                    .frame(width: 40, alignment: .leading)
                                    .foregroundStyle(.secondary)
                                GeometryReader { geo in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.orange.opacity(0.25))
                                        .frame(width: geo.size.width)
                                        .overlay(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.orange)
                                                .frame(width: max(8, geo.size.width * stat.ratio))
                                        }
                                }
                                .frame(height: 14)
                                Text("\(stat.minutes)m")
                                    .font(.caption.monospacedDigit())
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Highlights")
                            .font(.headline)
                        HighlightRow(title: "Longest streak", value: "5 days")
                        HighlightRow(title: "Best week", value: "6 workouts")
                        HighlightRow(title: "Total sessions", value: "42")
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("Progress")
            .background(Color(.systemGroupedBackground))
        }
    }

    private var weeklyStats: [(day: String, minutes: Int, ratio: CGFloat)] {
        [
            ("Mon", 45, 0.75),
            ("Tue", 30, 0.50),
            ("Wed", 60, 1.00),
            ("Thu", 0, 0.05),
            ("Fri", 40, 0.67),
            ("Sat", 55, 0.92),
            ("Sun", 20, 0.33),
        ]
    }
}

private struct HighlightRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProgressViewScreen()
}
