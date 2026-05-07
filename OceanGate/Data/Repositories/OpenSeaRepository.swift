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

    func collectionTraits(slug: String) async throws -> [CollectionTrait] {
        let response = try await client.fetchCollectionTraits(slug: slug)
        return response.traits
            .compactMap { traitType, category in
                category.values.max { lhs, rhs in lhs.value < rhs.value }.map { topValue, count in
                    CollectionTrait(type: traitType, topValue: topValue, count: count)
                }
            }
            .sorted { lhs, rhs in lhs.count > rhs.count }
    }

    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT] {
        let response = try await client.fetchNFTs(collectionSlug: collectionSlug, limit: limit)
        return response.nfts.map { NFT(dto: $0, fallbackCollectionSlug: collectionSlug) }
    }

    func nftDetail(nft: NFT, chain: String = "ethereum") async throws -> NFTDetail {
        async let detailResponse = client.fetchNFT(
            chain: chain,
            contractAddress: nft.contractAddress,
            identifier: nft.tokenIdentifier
        )
        async let listingSnapshot = bestListing(collectionSlug: nft.collectionSlug, identifier: nft.tokenIdentifier)

        let detailDTO = try await detailResponse.nft
        let detailedNFT = NFT(dto: detailDTO, fallbackCollectionSlug: nft.collectionSlug, fallbackNFT: nft)
        let listing = await listingSnapshot

        return NFTDetail(
            nft: detailedNFT,
            traits: detailDTO.traits?.map(NFTTrait.init(dto:)) ?? [],
            owners: detailDTO.owners?.compactMap(NFTOwner.init(dto:)) ?? [],
            rarity: detailDTO.rarity.map(NFTRarity.init(dto:)),
            tokenStandard: detailDTO.tokenStandard?.nilIfEmpty,
            animationURL: URL(string: detailDTO.animationUrl ?? ""),
            metadataURL: URL(string: detailDTO.metadataUrl ?? ""),
            bestListing: listing
        )
    }

    private func bestListing(collectionSlug: String, identifier: String) async -> NFTMarketListing? {
        do {
            let dto = try await client.fetchBestListing(collectionSlug: collectionSlug, identifier: identifier)
            return NFTMarketListing(dto: dto)
        } catch {
            return nil
        }
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
        self.init(dto: dto, fallbackCollectionSlug: fallbackCollectionSlug, fallbackNFT: nil)
    }

    init(dto: NFTDTO, fallbackCollectionSlug: String, fallbackNFT: NFT?) {
        let identifier = dto.identifier ?? UUID().uuidString
        let contract = dto.contract ?? fallbackNFT?.contractAddress ?? "unknown-contract"
        self.init(
            tokenIdentifier: identifier,
            collectionSlug: dto.collection ?? fallbackCollectionSlug,
            contractAddress: contract,
            name: dto.name?.nilIfEmpty ?? fallbackNFT?.name ?? "#\(identifier)",
            description: dto.description?.nilIfEmpty ?? fallbackNFT?.description,
            imageURL: URL(string: dto.imageUrl ?? "") ?? fallbackNFT?.imageURL,
            openseaURL: URL(string: dto.openseaUrl ?? "") ?? fallbackNFT?.openseaURL
        )
    }
}

private extension NFTTrait {
    init(dto: NFTTraitDTO) {
        self.init(
            type: dto.traitType?.nilIfEmpty ?? "Trait",
            value: dto.value?.displayValue.nilIfEmpty ?? "Unknown",
            displayType: dto.displayType?.nilIfEmpty,
            maxValue: dto.maxValue,
            count: dto.traitCount
        )
    }
}

private extension NFTOwner {
    init?(dto: NFTOwnerDTO) {
        guard let address = dto.address?.nilIfEmpty else { return nil }
        self.init(address: address, quantity: dto.quantity)
    }
}

private extension NFTRarity {
    init(dto: NFTRarityDTO) {
        self.init(rank: dto.rank, score: dto.score, maxRank: dto.maxRank)
    }
}

private extension NFTMarketListing {
    init?(dto: BestListingDTO) {
        guard dto.price?.current != nil || dto.orderHash != nil else { return nil }
        self.init(
            orderHash: dto.orderHash,
            chain: dto.chain,
            marketType: dto.type,
            price: dto.price?.current.flatMap(NFTPrice.init(dto:))
        )
    }
}

private extension NFTPrice {
    init?(dto: ListingPriceDTO) {
        guard let value = dto.value?.nilIfEmpty else { return nil }
        self.init(
            currency: dto.currency?.nilIfEmpty ?? "ETH",
            decimals: dto.decimals ?? 18,
            value: value
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
