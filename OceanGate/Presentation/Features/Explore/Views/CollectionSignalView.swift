import SwiftUI

struct CollectionSignalView: View {
    let phase: ExploreViewModel.Phase
    let traits: [CollectionTrait]
    let metrics: ExploreLayoutMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Spacer()

                if case .loaded = phase, !traits.isEmpty {
                    Text("\(traits.count) signals")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(NeonTheme.citrus)
                }
            }

            switch phase {
            case .idle, .loading:
                loadingGrid
            case .failed:
                EmptyView()
            case .loaded:
                traitsGrid
            }
        }
        .frame(width: metrics.contentWidth, alignment: .leading)
        .clipped()
    }

    private var loadingGrid: some View {
        LazyVGrid(columns: metrics.traitColumns, spacing: 10) {
            ForEach(0..<min(metrics.traitColumns.count, 6), id: \.self) { _ in
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(NeonTheme.glass)
                    .frame(height: 86)
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            }
        }
    }

    @ViewBuilder
    private var traitsGrid: some View {
        if !traits.isEmpty {
            LazyVGrid(columns: metrics.traitColumns, spacing: 10) {
                ForEach(Array(traits.prefix(metrics.traitColumns.count * 2).enumerated()), id: \.element.id) { index, trait in
                    TraitRadarCard(
                        trait: trait,
                        accent: NeonTheme.spectrum[index % NeonTheme.spectrum.count]
                    )
                }
            }
        }
    }
}

private struct TraitRadarCard: View {
    let trait: CollectionTrait
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)

                Text(trait.type.uppercased())
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }

            Text(trait.topValue)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(DisplayFormatters.compactNumber(Double(trait.count)))
                .font(.caption.weight(.bold))
                .foregroundStyle(accent)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
        .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.36), lineWidth: 1)
        }
    }
}
