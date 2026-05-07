import SwiftUI

struct CollectionHeroView: View {
    let collection: CollectionOverview
    let metrics: ExploreLayoutMetrics

    var body: some View {
        let width = metrics.contentWidth
        let innerWidth = max(0, width - 28)

        GlassPanel(cornerRadius: 30) {
            VStack(alignment: .leading, spacing: 18) {
                heroImage(innerWidth: innerWidth)

                Text(collection.description)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)

                LazyVGrid(columns: metrics.statColumns, spacing: 10) {
                    StatPill(title: "Floor", value: DisplayFormatters.eth(collection.stats.floorPrice), color: NeonTheme.mint)
                    StatPill(title: "Volume", value: DisplayFormatters.eth(collection.stats.volume), color: NeonTheme.cobalt)
                    StatPill(title: "Sales", value: DisplayFormatters.compactNumber(collection.stats.sales), color: NeonTheme.coral)
                    StatPill(title: "Owners", value: DisplayFormatters.compactNumber(collection.stats.owners), color: NeonTheme.citrus)
                }
                .frame(width: innerWidth)

                if let openseaURL = collection.openseaURL {
                    openSeaLink(openseaURL: openseaURL, innerWidth: innerWidth)
                }
            }
            .padding(14)
            .frame(width: width, alignment: .leading)
        }
        .frame(width: width, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
    }

    private func heroImage(innerWidth: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncNFTImage(url: collection.bannerImageURL ?? collection.imageURL, cornerRadius: 24)
                .frame(width: innerWidth, height: metrics.heroImageHeight)
                .cornerRadius(30)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.74)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }

            HStack(alignment: .bottom, spacing: 14) {
                AsyncNFTImage(url: collection.imageURL, cornerRadius: 18)
                    .frame(width: 86, height: 86)
                    .overlay {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 5) {
                    Text(collection.name)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(collection.slug)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(NeonTheme.mint)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .frame(width: innerWidth, alignment: .leading)
        }
        .frame(width: innerWidth)
        .clipped()
    }

    private func openSeaLink(openseaURL: URL, innerWidth: CGFloat) -> some View {
        HStack {
            Spacer(minLength: 0)

            Link(destination: openseaURL) {
                Label("Open on OpenSea", systemImage: "safari.fill")
                    .font(.headline.weight(.bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, 24)
                    .frame(maxWidth: min(300, innerWidth * 0.82))
            }
            .buttonStyle(.borderedProminent)
            .tint(NeonTheme.mint)

            Spacer(minLength: 0)
        }
        .frame(width: innerWidth)
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)

            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white.opacity(0.48))

                Text(value)
                    .font(.footnote.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
