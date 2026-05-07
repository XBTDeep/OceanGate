import Foundation
import Observation

@MainActor
@Observable
final class ExploreViewModel {
    enum Phase: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    private let service: OpenSeaServicing
    private let featuredSlugs = [
        "pudgypenguins",
        "azuki",
        "doodles-official",
        "clonex",
        "boredapeyachtclub",
        "moonbirds"
    ]

    var phase: Phase = .idle
    var nftPhase: Phase = .idle
    var traitPhase: Phase = .idle
    var collections: [CollectionOverview] = []
    var selectedSlug = "pudgypenguins"
    var nfts: [NFT] = []
    var collectionTraits: [CollectionTrait] = []

    var selectedCollection: CollectionOverview? {
        collections.first { $0.slug == selectedSlug } ?? collections.first
    }

    init(service: OpenSeaServicing) {
        self.service = service
    }

    func start() async {
        guard phase == .idle else { return }
        await refresh()
    }

    func refresh() async {
        phase = .loading

        do {
            collections = try await loadCollections()
            phase = .loaded

            if let firstSlug = collections.first?.slug, selectedCollection == nil {
                selectedSlug = firstSlug
            }

            await selectCollection(slug: selectedSlug)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func selectCollection(slug: String) async {
        guard selectedSlug != slug || nfts.isEmpty else { return }
        selectedSlug = slug
        nftPhase = .loading
        traitPhase = .loading

        async let loadedNFTs = service.nfts(in: slug, limit: 36)
        async let loadedTraits = service.collectionTraits(slug: slug)

        do {
            nfts = try await loadedNFTs
            nftPhase = .loaded
        } catch {
            nfts = []
            nftPhase = .failed(error.localizedDescription)
        }

        do {
            collectionTraits = try await loadedTraits
            traitPhase = .loaded
        } catch {
            collectionTraits = []
            traitPhase = .failed(error.localizedDescription)
        }
    }

    func detailViewModel(for nft: NFT) -> NFTDetailViewModel {
        NFTDetailViewModel(nft: nft, service: service)
    }

    private func loadCollections() async throws -> [CollectionOverview] {
        let (loadedCollections, lastError) = await withTaskGroup(of: Result<CollectionOverview, Error>.self) { group in
            for slug in featuredSlugs {
                group.addTask { [service] in
                    do {
                        return .success(try await service.collection(slug: slug))
                    } catch {
                        return .failure(error)
                    }
                }
            }

            var loadedCollections: [CollectionOverview] = []
            var lastError: Error?
            for await result in group {
                switch result {
                case let .success(collection):
                    loadedCollections.append(collection)
                case let .failure(error):
                    lastError = error
                }
            }

            let sortedCollections = loadedCollections.sorted { lhs, rhs in
                let lhsIndex = featuredSlugs.firstIndex(of: lhs.slug) ?? Int.max
                let rhsIndex = featuredSlugs.firstIndex(of: rhs.slug) ?? Int.max
                return lhsIndex < rhsIndex
            }

            return (sortedCollections, lastError)
        }

        guard !loadedCollections.isEmpty else {
            throw lastError ?? OpenSeaAPIError.invalidResponse
        }

        return loadedCollections
    }
}

@MainActor
@Observable
final class NFTDetailViewModel {
    private let service: OpenSeaServicing

    let seedNFT: NFT
    var phase: ExploreViewModel.Phase = .idle
    var detail: NFTDetail?

    var displayNFT: NFT {
        detail?.nft ?? seedNFT
    }

    init(nft: NFT, service: OpenSeaServicing) {
        seedNFT = nft
        self.service = service
    }

    func start() async {
        guard phase == .idle else { return }
        await refresh()
    }

    func refresh() async {
        phase = .loading

        do {
            detail = try await service.nftDetail(nft: seedNFT, chain: "ethereum")
            phase = .loaded
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
