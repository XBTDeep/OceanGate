import SwiftUI

struct NFTDetailView: View {
    @State private var viewModel: NFTDetailViewModel

    init(viewModel: NFTDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        let nft = viewModel.displayNFT
        let detail = viewModel.detail

        GeometryReader { geometry in
            let metrics = ExploreLayoutMetrics.detail(size: geometry.size)

            ZStack {
                AnimatedNeonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        DetailHeaderView(nft: nft, phase: viewModel.phase, detail: detail, metrics: metrics) {
                            Task { await viewModel.refresh() }
                        }

                        if let detail {
                            DetailInfoGrid(detail: detail, columns: metrics.statColumns)

                            if !detail.traits.isEmpty {
                                DetailTraitGrid(traits: detail.traits, columns: metrics.traitColumns)
                            }

                            if !detail.owners.isEmpty {
                                DetailOwnersView(owners: detail.owners, columns: metrics.statColumns)
                            }
                        }
                    }
                    .frame(width: metrics.detailContentWidth, alignment: .leading)
                    .padding(.horizontal, metrics.detailHorizontalPadding)
                    .padding(.top, metrics.topPadding)
                    .padding(.bottom, 34)
                    .frame(width: geometry.size.width, alignment: .center)
                }
            }
        }
        .navigationTitle(nft.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.start()
        }
    }
}

private struct DetailHeaderView: View {
    let nft: NFT
    let phase: ExploreViewModel.Phase
    let detail: NFTDetail?
    let metrics: ExploreLayoutMetrics
    let retry: () -> Void

    var body: some View {
        if metrics.viewportWidth >= 820 {
            HStack(alignment: .top, spacing: 24) {
                DetailImageView(nft: nft, phase: phase, imageSize: min(430, metrics.detailContentWidth * 0.46))

                VStack(alignment: .leading, spacing: 18) {
                    DetailTitleView(nft: nft)
                    DetailMarketPanel(nft: nft, detail: detail, phase: phase, retry: retry)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            DetailImageView(nft: nft, phase: phase, imageSize: metrics.detailContentWidth)

            DetailTitleView(nft: nft)

            DetailMarketPanel(nft: nft, detail: detail, phase: phase, retry: retry)
        }
    }
}

private struct DetailImageView: View {
    let nft: NFT
    let phase: ExploreViewModel.Phase
    let imageSize: CGFloat

    var body: some View {
        AsyncNFTImage(url: nft.imageURL, cornerRadius: 30)
            .frame(width: imageSize, height: imageSize)
            .overlay(alignment: .topLeading) {
                Label(nft.collectionSlug, systemImage: "circle.hexagongrid.fill")
                    .font(.caption.weight(.black))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.black.opacity(0.48), in: Capsule())
                    .padding(14)
            }
            .overlay(alignment: .bottomTrailing) {
                if case .loading = phase {
                    ProgressView()
                        .tint(.white)
                        .padding(12)
                        .background(.black.opacity(0.5), in: Circle())
                        .padding(14)
                }
            }
    }
}

private struct DetailTitleView: View {
    let nft: NFT

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(nft.name)
                .font(.system(size: 31, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text("#\(nft.tokenIdentifier)")
                .font(.headline.weight(.black))
                .foregroundStyle(NeonTheme.mint)

            if let description = nft.description {
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 4)
    }
}

private struct DetailMarketPanel: View {
    let nft: NFT
    let detail: NFTDetail?
    let phase: ExploreViewModel.Phase
    let retry: () -> Void

    var body: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: 14) {
                marketSummary

                switch phase {
                case let .failed(message):
                    retryMessage(message)
                default:
                    if let openseaURL = nft.openseaURL {
                        Link(destination: openseaURL) {
                            Label("Open on OpenSea", systemImage: "safari.fill")
                                .font(.headline.weight(.bold))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(NeonTheme.cobalt)
                    }
                }
            }
            .padding(18)
        }
    }

    private var marketSummary: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Best Listing")
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white.opacity(0.48))

                Text(DisplayFormatters.price(detail?.bestListing?.price))
                    .font(.system(size: 27, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

            Spacer(minLength: 12)

            if let rank = detail?.rarity?.rank {
                VStack(alignment: .trailing, spacing: 5) {
                    Text("Rarity")
                        .font(.caption.weight(.black))
                        .foregroundStyle(.white.opacity(0.48))

                    Text("#\(rank)")
                        .font(.title3.weight(.black))
                        .foregroundStyle(NeonTheme.citrus)
                }
            }
        }
    }

    private func retryMessage(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(message)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)

            Button(action: retry) {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(NeonTheme.coral)
        }
    }
}

private struct DetailInfoGrid: View {
    let detail: NFTDetail
    let columns: [GridItem]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            DetailInfoTile(title: "Standard", value: detail.tokenStandard?.uppercased() ?? "N/A", color: NeonTheme.mint)
            DetailInfoTile(title: "Traits", value: "\(detail.traits.count)", color: NeonTheme.cobalt)
            DetailInfoTile(title: "Owners", value: "\(detail.owners.count)", color: NeonTheme.coral)
            DetailInfoTile(title: "Score", value: DisplayFormatters.rarity(detail.rarity?.score), color: NeonTheme.citrus)
        }
    }
}

private struct DetailInfoTile: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.48))

            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
        .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DetailTraitGrid: View {
    let traits: [NFTTrait]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Traits")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(traits.enumerated()), id: \.element.id) { index, trait in
                    DetailTraitTile(trait: trait, accent: NeonTheme.spectrum[index % NeonTheme.spectrum.count])
                }
            }
        }
    }
}

private struct DetailTraitTile: View {
    let trait: NFTTrait
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(trait.type.uppercased())
                .font(.caption2.weight(.black))
                .foregroundStyle(.white.opacity(0.48))
                .lineLimit(1)

            Text(trait.value)
                .font(.subheadline.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if let count = trait.count {
                Text(DisplayFormatters.compactNumber(Double(count)))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 82, alignment: .leading)
        .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct DetailOwnersView: View {
    let owners: [NFTOwner]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Owners")
                .font(.title3.weight(.black))
                .foregroundStyle(.white)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(owners.prefix(8)) { owner in
                    DetailOwnerTile(owner: owner)
                }
            }
        }
    }
}

private struct DetailOwnerTile: View {
    let owner: NFTOwner

    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.hexagon.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(NeonTheme.mint)

            Text(DisplayFormatters.compactAddress(owner.address))
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            if let quantity = owner.quantity {
                Text("x\(quantity)")
                    .font(.caption.weight(.black))
                    .foregroundStyle(NeonTheme.citrus)
            }
        }
        .padding(14)
        .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
