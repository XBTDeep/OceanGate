import Foundation

final class OpenSeaRepository: OpenSeaServicing {
    private let client: OpenSeaAPIClienting

    init(client: OpenSeaAPIClienting) {
        self.client = client
    }

    func collection(slug: String) async throws -> CollectionOverview {
        async let details = client.fetchCollection(slug: slug)
        async let stats = client.fetchCollectionStats(slug: slug)

        return try await CollectionOverview(dto: details, statsDTO: stats.total, fallbackSlug: slug)
    }

    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT] {
        let response = try await client.fetchNFTs(collectionSlug: collectionSlug, limit: limit)
        return response.nfts.map { NFT(dto: $0, fallbackCollectionSlug: collectionSlug) }
    }
}

private extension CollectionOverview {
    init(dto: CollectionDTO, statsDTO: CollectionStatsDTO?, fallbackSlug: String) {
        let slug = dto.collection ?? fallbackSlug
        self.init(
            slug: slug,
            name: dto.name ?? slug.displayNameFromSlug,
            description: dto.description ?? "A live collection from OpenSea.",
            imageURL: URL(string: dto.imageUrl ?? ""),
            bannerImageURL: URL(string: dto.bannerImageUrl ?? ""),
            openseaURL: URL(string: dto.openseaUrl ?? ""),
            stats: CollectionStats(
                floorPrice: statsDTO?.floorPrice,
                volume: statsDTO?.volume,
                sales: statsDTO?.sales,
                owners: statsDTO?.numOwners
            )
        )
    }
}

private extension NFT {
    init(dto: NFTDTO, fallbackCollectionSlug: String) {
        let identifier = dto.identifier ?? UUID().uuidString
        let contract = dto.contract ?? "unknown-contract"
        self.init(
            tokenIdentifier: identifier,
            collectionSlug: dto.collection ?? fallbackCollectionSlug,
            contractAddress: contract,
            name: dto.name?.nilIfEmpty ?? "#\(identifier)",
            description: dto.description?.nilIfEmpty,
            imageURL: URL(string: dto.imageUrl ?? ""),
            openseaURL: URL(string: dto.openseaUrl ?? "")
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    var displayNameFromSlug: String {
        split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

