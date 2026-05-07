import SwiftUI

struct ExploreView: View {
    @State private var viewModel: ExploreViewModel
    @Namespace private var selectionNamespace

    init(viewModel: ExploreViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let metrics = ExploreLayoutMetrics(size: geometry.size)

                ZStack {
                    AnimatedNeonBackground()

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            ExploreHeaderView(width: metrics.contentWidth)

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
                                ExploreLoadedContentView(
                                    viewModel: viewModel,
                                    selectionNamespace: selectionNamespace,
                                    metrics: metrics
                                )
                            }
                        }
                        .frame(width: metrics.contentWidth, alignment: .leading)
                        .padding(.top, metrics.topPadding)
                        .padding(.bottom, 34)
                        .frame(width: geometry.size.width, alignment: .leading)
                        .padding(.horizontal, metrics.horizontalPadding)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .navigationDestination(for: NFT.self) { nft in
                NFTDetailView(viewModel: viewModel.detailViewModel(for: nft))
            }
            .task {
                await viewModel.start()
            }
        }
    }
}

private struct ExploreLoadedContentView: View {
    let viewModel: ExploreViewModel
    let selectionNamespace: Namespace.ID
    let metrics: ExploreLayoutMetrics

    var body: some View {
        if let selectedCollection = viewModel.selectedCollection {
            CollectionHeroView(collection: selectedCollection, metrics: metrics)

            CollectionRailView(
                collections: viewModel.collections,
                selectedSlug: viewModel.selectedSlug,
                namespace: selectionNamespace,
                width: metrics.contentWidth
            ) { slug in
                Task { await viewModel.selectCollection(slug: slug) }
            }

            CollectionSignalView(
                phase: viewModel.traitPhase,
                traits: viewModel.collectionTraits,
                metrics: metrics
            )

            NFTOrbitSection(
                phase: viewModel.nftPhase,
                nfts: viewModel.nfts,
                metrics: metrics,
                isLoadingMore: viewModel.isLoadingMoreNFTs,
                hasMoreNFTs: viewModel.hasMoreNFTs,
                paginationErrorMessage: viewModel.paginationErrorMessage,
                onLoadMore: {
                    Task { await viewModel.loadMoreNFTs() }
                },
                onApproachEnd: { nft in
                    Task { await viewModel.loadMoreNFTsIfNeeded(currentNFT: nft) }
                }
            )
        }
    }
}

#Preview {
    ExploreView(viewModel: ExploreViewModel(service: PreviewOpenSeaService()))
}
