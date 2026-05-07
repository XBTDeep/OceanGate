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
    var collections: [CollectionOverview] = []
    var selectedSlug = "pudgypenguins"
    var nfts: [NFT] = []
    var selectedNFT: NFT?

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

        do {
            nfts = try await service.nfts(in: slug, limit: 36)
            nftPhase = .loaded
        } catch {
            nfts = []
            nftPhase = .failed(error.localizedDescription)
        }
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
