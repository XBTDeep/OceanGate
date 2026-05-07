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
    private let nftPageSize = 72
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
    var isLoadingMoreNFTs = false
    var hasMoreNFTs = false
    var paginationErrorMessage: String?
    private var nftNextCursor: String?

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

            await selectCollection(slug: selectedSlug, force: true)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func selectCollection(slug: String, force: Bool = false) async {
        guard force || selectedSlug != slug || nfts.isEmpty else { return }
        selectedSlug = slug
        nftPhase = .loading
        traitPhase = .loading
        nfts = []
        collectionTraits = []
        nftNextCursor = nil
        hasMoreNFTs = false
        isLoadingMoreNFTs = false
        paginationErrorMessage = nil

        async let loadedNFTPage = service.nftsPage(in: slug, limit: nftPageSize, cursor: nil)
        async let loadedTraits = service.collectionTraits(slug: slug)

        do {
            let page = try await loadedNFTPage
            guard selectedSlug == slug else { return }
            nfts = page.nfts
            nftNextCursor = page.nextCursor
            hasMoreNFTs = page.nextCursor != nil
            nftPhase = .loaded
        } catch {
            guard selectedSlug == slug else { return }
            nfts = []
            nftNextCursor = nil
            hasMoreNFTs = false
            nftPhase = .failed(error.localizedDescription)
        }

        do {
            let traits = try await loadedTraits
            guard selectedSlug == slug else { return }
            collectionTraits = traits
            traitPhase = .loaded
        } catch {
            guard selectedSlug == slug else { return }
            collectionTraits = []
            traitPhase = .failed(error.localizedDescription)
        }
    }

    func loadMoreNFTsIfNeeded(currentNFT: NFT?) async {
        guard let currentNFT else { return }
        guard nfts.suffix(8).contains(currentNFT) else { return }
        await loadMoreNFTs()
    }

    func loadMoreNFTs() async {
        guard !isLoadingMoreNFTs, let cursor = nftNextCursor else { return }

        let slug = selectedSlug
        isLoadingMoreNFTs = true
        paginationErrorMessage = nil
        defer { isLoadingMoreNFTs = false }

        do {
            let page = try await service.nftsPage(in: slug, limit: nftPageSize, cursor: cursor)
            guard selectedSlug == slug else { return }

            let existingIDs = Set(nfts.map(\.id))
            let freshNFTs = page.nfts.filter { !existingIDs.contains($0.id) }
            nfts.append(contentsOf: freshNFTs)
            nftNextCursor = page.nextCursor
            hasMoreNFTs = page.nextCursor != nil
        } catch {
            guard selectedSlug == slug else { return }
            paginationErrorMessage = error.localizedDescription
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
