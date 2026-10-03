import SwiftUI

struct CelebrationPayload: Identifiable {
    let id = UUID()
    let workoutTitle: String
    let sessionWeight: Double
    let allTimeWeight: Double
    let streak: Int
    let closedTheWeek: Bool
}

struct CelebrationView: View {
    let payload: CelebrationPayload
    let onDone: () -> Void
    @State private var burst = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.orange.opacity(colorScheme == .dark ? 0.55 : 0.38),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ConfettiBurst(running: burst)

            VStack(spacing: 22) {
                Spacer(minLength: 12)

                Image(systemName: payload.streak >= 4 && payload.streak % 4 == 0 ? "trophy.fill" : "checkmark.seal.fill")
                    .font(.system(size: 76))
                    .foregroundStyle(.orange)
                    .shadow(color: .orange.opacity(0.45), radius: burst ? 18 : 0)
                    .symbolEffect(.bounce, value: burst)

                VStack(spacing: 8) {
                    Text(WorkoutStats.celebrationTitle(streak: payload.streak, closedTheWeek: payload.closedTheWeek))
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text(payload.workoutTitle)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.orange)
                    Text(WorkoutStats.celebrationDetail(streak: payload.streak, closedTheWeek: payload.closedTheWeek))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 12) {
                    statRow(title: "This session", value: "\(formatPoundsGrouped(payload.sessionWeight)) lb", caption: "Weight moved")
                    statRow(title: "All time", value: "\(formatPoundsGrouped(payload.allTimeWeight)) lb", caption: "Weight moved")
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))

                Text("Total weight moved adds the weight of each set you checked off. Reps aren't tracked, so this is not weight × reps.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: onDone) {
                    Text("Nice")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.orange, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 8)
            }
            .padding(24)
        }
        .onAppear { burst = true }
    }

    private func statRow(title: String, value: String, caption: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.orange)
                .monospacedDigit()
        }
    }
}

private struct ConfettiPiece: Identifiable {
    let id: Int
    let x: CGFloat
    let drift: CGFloat
    let spin: Double
    let duration: Double
    let delay: Double
    let color: Color
    let width: CGFloat
    let height: CGFloat

    static func makeAll() -> [ConfettiPiece] {
        let colors: [Color] = [.orange, .yellow, .pink, .mint, .red]
        var pieces: [ConfettiPiece] = []
        pieces.reserveCapacity(52)
        for index in 0..<52 {
            let x = CGFloat(index * 37 % 100) / 100
            let drift = CGFloat((index % 9) - 4) * 16
            let spin = Double((index * 47) % 360)
            let duration = 2.2 + Double(index % 6) * 0.28
            let delay = Double(index % 10) * 0.06
            let color = colors[index % colors.count]
            let width: CGFloat = index % 3 == 0 ? 7 : 10
            let height = CGFloat(12 + (index % 4) * 4)
            pieces.append(ConfettiPiece(
                id: index,
                x: x,
                drift: drift,
                spin: spin,
                duration: duration,
                delay: delay,
                color: color,
                width: width,
                height: height
            ))
        }
        return pieces
    }
}

private struct ConfettiBit: View {
    let piece: ConfettiPiece
    let running: Bool
    let size: CGSize

    var body: some View {
        let x = piece.x * size.width + (running ? piece.drift : 0)
        let y = running ? size.height + 40 : -30
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: piece.width, height: piece.height)
            .rotationEffect(.degrees(running ? piece.spin + 280 : piece.spin))
            .position(x: x, y: y)
            .animation(.easeIn(duration: piece.duration).delay(piece.delay), value: running)
    }
}

private struct ConfettiBurst: View {
    var running: Bool
    private let pieces = ConfettiPiece.makeAll()

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiBit(piece: piece, running: running, size: size)
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
