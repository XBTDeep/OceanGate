import SwiftUI

struct AnimatedNeonBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(NeonTheme.ink))

                for index in 0..<6 {
                    let phase = time * (0.16 + Double(index) * 0.025)
                    let x = size.width * (0.5 + 0.45 * CGFloat(sin(phase + Double(index))))
                    let y = size.height * (0.5 + 0.42 * CGFloat(cos(phase * 1.17 + Double(index))))
                    let radius = min(size.width, size.height) * CGFloat(0.34 + Double(index % 3) * 0.08)
                    let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)

                    context.opacity = 0.23
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .radialGradient(
                            Gradient(colors: [NeonTheme.spectrum[index % NeonTheme.spectrum.count], .clear]),
                            center: CGPoint(x: x, y: y),
                            startRadius: 0,
                            endRadius: radius
                        )
                    )
                }

                context.opacity = 0.18
                for index in stride(from: 0, to: 54, by: 1) {
                    let angle = Double(index) * 0.73 + time * 0.05
                    let x = size.width * CGFloat(0.5 + 0.48 * sin(angle))
                    let y = size.height * CGFloat(0.5 + 0.48 * cos(angle * 1.4))
                    let dot = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(ellipseIn: dot), with: .color(.white))
                }
            }
            .ignoresSafeArea()
        }
    }
}

