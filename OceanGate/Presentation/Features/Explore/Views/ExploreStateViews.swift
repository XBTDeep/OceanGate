import SwiftUI

struct LoadingPulseView: View {
    let title: String

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let scale = 1 + 0.08 * sin(time * 3)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: NeonTheme.spectrum,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 8
                        )
                        .frame(width: 72, height: 72)
                        .scaleEffect(scale)

                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.78))
            }
        }
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: (() -> Void)?

    init(message: String, retry: (() -> Void)?) {
        self.message = message
        self.retry = retry
    }

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                Image(systemName: "bolt.trianglebadge.exclamationmark.fill")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(NeonTheme.coral)

                Text("Signal lost")
                    .font(.title3.weight(.black))
                    .foregroundStyle(.white)

                Text(message)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.72))

                if let retry {
                    Button(action: retry) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.headline.weight(.bold))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NeonTheme.cobalt)
                }
            }
            .padding(20)
        }
    }
}
