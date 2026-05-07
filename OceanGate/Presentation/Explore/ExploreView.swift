import SwiftUI

struct ExploreView: View {
    @State private var viewModel: ExploreViewModel
    @Namespace private var selectionNamespace

    init(viewModel: ExploreViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding: CGFloat = 20
            let contentWidth = max(0, geometry.size.width - horizontalPadding * 2)

            ZStack {
                AnimatedNeonBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header(width: contentWidth)

                        switch viewModel.phase {
                        case .idle, .loading:
                            LoadingPulseView(title: "Tuning the atlas")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                        case let .failed(message):
                            ErrorStateView(message: message) {
                                Task { await viewModel.refresh() }
                            }
                        case .loaded:
                            content(width: contentWidth, viewportWidth: geometry.size.width, horizontalPadding: horizontalPadding)
                        }
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.top, 18)
                    .padding(.bottom, 34)
                    .frame(width: geometry.size.width, alignment: .leading)
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .task {
            await viewModel.start()
        }
        .sheet(item: $viewModel.selectedNFT) { nft in
            NFTDetailView(nft: nft)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private func header(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "circle.hexagongrid.circle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(LinearGradient(colors: [NeonTheme.mint, NeonTheme.coral], startPoint: .topLeading, endPoint: .bottomTrailing))

                Text("Ocean Gate")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("Live OpenSea collections as kinetic galleries.")
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
        .frame(width: width, alignment: .leading)
    }

    @ViewBuilder
    private func content(width: CGFloat, viewportWidth: CGFloat, horizontalPadding: CGFloat) -> some View {
        if let selectedCollection = viewModel.selectedCollection {
            CollectionHeroView(collection: selectedCollection, width: width)

            CollectionRailView(
                collections: viewModel.collections,
                selectedSlug: viewModel.selectedSlug,
                namespace: selectionNamespace,
                width: viewportWidth
            ) { slug in
                Task { await viewModel.selectCollection(slug: slug) }
            }
            .offset(x: -horizontalPadding)

            NFTOrbitSection(phase: viewModel.nftPhase, nfts: viewModel.nfts, width: width) { nft in
                viewModel.selectedNFT = nft
            }
        }
    }
}

private struct CollectionHeroView: View {
    let collection: CollectionOverview
    let width: CGFloat

    var body: some View {
        let innerWidth = max(0, width - 28)

        GlassPanel(cornerRadius: 30) {
            VStack(alignment: .leading, spacing: 18) {
                ZStack(alignment: .bottomLeading) {
                    AsyncNFTImage(url: collection.bannerImageURL ?? collection.imageURL, cornerRadius: 24)
                        .frame(width: innerWidth, height: 230)
                        .cornerRadius(30)
                        .clipped()
                        .overlay {
                            LinearGradient(colors: [.clear, .black.opacity(0.74)], startPoint: .center, endPoint: .bottom)
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

                Text(collection.description)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: innerWidth, alignment: .leading)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 0), spacing: 10), count: 2), spacing: 10) {
                    StatPill(title: "Floor", value: DisplayFormatters.eth(collection.stats.floorPrice), color: NeonTheme.mint)
                    StatPill(title: "Volume", value: DisplayFormatters.eth(collection.stats.volume), color: NeonTheme.cobalt)
                    StatPill(title: "Sales", value: DisplayFormatters.compactNumber(collection.stats.sales), color: NeonTheme.coral)
                    StatPill(title: "Owners", value: DisplayFormatters.compactNumber(collection.stats.owners), color: NeonTheme.citrus)
                }
                .frame(width: innerWidth)

                if let openseaURL = collection.openseaURL {
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
            .padding(14)
            .frame(width: width, alignment: .leading)
        }
        .frame(width: width, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
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

private struct CollectionRailView: View {
    let collections: [CollectionOverview]
    let selectedSlug: String
    let namespace: Namespace.ID
    let width: CGFloat
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(collections) { collection in
                    Button {
                        onSelect(collection.slug)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            AsyncNFTImage(url: collection.imageURL, cornerRadius: 18)
                                .frame(width: 84, height: 84)

                            Text(collection.name)
                                .font(.caption.weight(.black))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .frame(width: 104, alignment: .leading)
                        }
                        .padding(10)
                        .background {
                            if selectedSlug == collection.slug {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(LinearGradient(colors: [NeonTheme.cobalt.opacity(0.34), NeonTheme.coral.opacity(0.28)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .matchedGeometryEffect(id: "selectedCollection", in: namespace)
                            } else {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .fill(NeonTheme.glass)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 0)
        }
        .frame(width: width, alignment: .leading)
        .clipped()
    }
}

private struct NFTOrbitSection: View {
    let phase: ExploreViewModel.Phase
    let nfts: [NFT]
    let width: CGFloat
    var onSelect: (NFT) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Signal Stream")
                    .font(.title2.weight(.black))
                Spacer()
                Text("\(nfts.count) live NFTs")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(NeonTheme.mint)
            }

            switch phase {
            case .idle, .loading:
                LoadingPulseView(title: "Pulling tokens")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 38)
            case let .failed(message):
                ErrorStateView(message: message, retry: nil)
            case .loaded:
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 14)], spacing: 14) {
                    ForEach(Array(nfts.prefix(30).enumerated()), id: \.element.id) { index, nft in
                        NFTCard(nft: nft, accent: NeonTheme.spectrum[index % NeonTheme.spectrum.count]) {
                            onSelect(nft)
                        }
                    }
                }
            }
        }
        .frame(width: width, alignment: .leading)
        .clipped()
    }
}

private struct NFTCard: View {
    let nft: NFT
    let accent: Color
    let onSelect: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                AsyncNFTImage(url: nft.imageURL, cornerRadius: 20)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(alignment: .topTrailing) {
                        Image(systemName: "sparkle")
                            .font(.caption.weight(.black))
                            .padding(8)
                            .background(.black.opacity(0.36), in: Circle())
                            .padding(8)
                    }

                Text(nft.name)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .frame(minHeight: 38, alignment: .topLeading)

                Text("#\(nft.tokenIdentifier)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
                    .lineLimit(1)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(NeonTheme.glass, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(accent.opacity(0.55), lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.32, dampingFraction: 0.72), value: isPressed)
            .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .buttonStyle(.plain)
    }
}

private struct NFTDetailView: View {
    let nft: NFT

    var body: some View {
        ZStack {
            AnimatedNeonBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    AsyncNFTImage(url: nft.imageURL, cornerRadius: 30)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(alignment: .topLeading) {
                            Label(nft.collectionSlug, systemImage: "circle.hexagongrid.fill")
                                .font(.caption.weight(.black))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.black.opacity(0.48), in: Capsule())
                                .padding(14)
                        }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(nft.name)
                            .font(.system(size: 31, weight: .black, design: .rounded))
                            .foregroundStyle(.white)

                        Text("#\(nft.tokenIdentifier)")
                            .font(.headline.weight(.black))
                            .foregroundStyle(NeonTheme.mint)

                        if let description = nft.description {
                            Text(description)
                                .font(.callout)
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        if let openseaURL = nft.openseaURL {
                            Link(destination: openseaURL) {
                                Label("View Listing", systemImage: "safari.fill")
                                    .font(.headline.weight(.bold))
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(NeonTheme.cobalt)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(20)
            }
        }
    }
}

private struct LoadingPulseView: View {
    let title: String

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let scale = 1 + 0.08 * sin(time * 3)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(LinearGradient(colors: NeonTheme.spectrum, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 8)
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

private struct ErrorStateView: View {
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

#Preview {
    ExploreView(viewModel: ExploreViewModel(service: PreviewOpenSeaService()))
}
