import SwiftUI

struct NFTOrbitSection: View {
    let phase: ExploreViewModel.Phase
    let nfts: [NFT]
    let metrics: ExploreLayoutMetrics
    let isLoadingMore: Bool
    let hasMoreNFTs: Bool
    let paginationErrorMessage: String?
    let onLoadMore: () -> Void
    let onApproachEnd: (NFT) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader

            switch phase {
            case .idle, .loading:
                LoadingPulseView(title: "Pulling tokens")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 38)
            case let .failed(message):
                ErrorStateView(message: message, retry: nil)
            case .loaded:
                nftGrid

                NFTPaginationFooter(
                    isLoadingMore: isLoadingMore,
                    hasMoreNFTs: hasMoreNFTs,
                    errorMessage: paginationErrorMessage,
                    onLoadMore: onLoadMore
                )
            }
        }
        .frame(width: metrics.contentWidth, alignment: .leading)
        .clipped()
    }

    private var sectionHeader: some View {
        HStack {
            Text("NFT Stream")
                .font(.title2.weight(.black))

            Spacer()

            Text("\(nfts.count) live NFTs")
                .font(.caption.weight(.bold))
                .foregroundStyle(NeonTheme.mint)
        }
    }

    private var nftGrid: some View {
        LazyVGrid(columns: metrics.nftColumns, spacing: 16) {
            ForEach(Array(nfts.enumerated()), id: \.element.id) { index, nft in
                NavigationLink(value: nft) {
                    NFTCard(nft: nft, accent: NeonTheme.spectrum[index % NeonTheme.spectrum.count])
                }
                .buttonStyle(.plain)
                .onAppear {
                    onApproachEnd(nft)
                }
            }
        }
    }
}

private struct NFTPaginationFooter: View {
    let isLoadingMore: Bool
    let hasMoreNFTs: Bool
    let errorMessage: String?
    let onLoadMore: () -> Void

    var body: some View {
        Group {
            if isLoadingMore {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(.white)

                    Text("Loading more NFTs")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.68))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else if let errorMessage {
                VStack(spacing: 10) {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Button(action: onLoadMore) {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.caption.weight(.black))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(NeonTheme.coral)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
            } else if !hasMoreNFTs {
                Text("End of collection page stream")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.48))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
        }
    }
}

private struct NFTCard: View {
    let nft: NFT
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncNFTImage(url: nft.imageURL, cornerRadius: 20)
                .aspectRatio(1, contentMode: .fit)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.headline.weight(.black))
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
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
