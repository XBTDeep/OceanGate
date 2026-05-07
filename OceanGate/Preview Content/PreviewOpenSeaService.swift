import Foundation

struct PreviewOpenSeaService: OpenSeaServicing {
    func collection(slug: String) async throws -> CollectionOverview {
        CollectionOverview(
            slug: slug,
            name: slug.split(separator: "-").map(\.capitalized).joined(separator: " "),
            description: "Preview signal for a collection rendered through the Neon Atlas experience.",
            imageURL: URL(string: "https://picsum.photos/seed/\(slug)/400"),
            bannerImageURL: URL(string: "https://picsum.photos/seed/\(slug)-banner/900/500"),
            openseaURL: nil,
            stats: CollectionStats(floorPrice: 1.2, volume: 84520, sales: 12034, owners: 5981)
        )
    }

    func collectionTraits(slug: String) async throws -> [CollectionTrait] {
        [
            CollectionTrait(type: "Background", topValue: "Aurora", count: 1240),
            CollectionTrait(type: "Eyes", topValue: "Laser", count: 680),
            CollectionTrait(type: "Mood", topValue: "Cosmic", count: 512),
            CollectionTrait(type: "Signal", topValue: "Mint", count: 288)
        ]
    }

    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT] {
        (0..<limit).map { index in
            NFT(
                tokenIdentifier: "\(1000 + index)",
                collectionSlug: collectionSlug,
                contractAddress: "preview",
                name: "Atlas Signal \(index + 1)",
                description: nil,
                imageURL: URL(string: "https://picsum.photos/seed/\(collectionSlug)-\(index)/500"),
                openseaURL: nil
            )
        }
    }

    func nftDetail(nft: NFT, chain: String) async throws -> NFTDetail {
        NFTDetail(
            nft: NFT(
                tokenIdentifier: nft.tokenIdentifier,
                collectionSlug: nft.collectionSlug,
                contractAddress: nft.contractAddress,
                name: nft.name,
                description: "A hydrated preview token with trait metadata, owner hints, rarity and a live-style market panel.",
                imageURL: nft.imageURL,
                openseaURL: nft.openseaURL
            ),
            traits: [
                NFTTrait(type: "Background", value: "Aurora", displayType: nil, maxValue: nil, count: 1240),
                NFTTrait(type: "Eyes", value: "Laser", displayType: nil, maxValue: nil, count: 680),
                NFTTrait(type: "Signal", value: "Mint", displayType: nil, maxValue: nil, count: 288),
                NFTTrait(type: "Power", value: "92", displayType: "number", maxValue: 100, count: nil)
            ],
            owners: [NFTOwner(address: "0x9e8f7c6a4b3d2e1f00112233445566778899aabb", quantity: 1)],
            rarity: NFTRarity(rank: 314, score: 82.7, maxRank: 10000),
            tokenStandard: "erc721",
            animationURL: nil,
            metadataURL: URL(string: "https://example.com/metadata/\(nft.tokenIdentifier)"),
            bestListing: NFTMarketListing(
                orderHash: "preview-order",
                chain: chain,
                marketType: "basic",
                price: NFTPrice(currency: "ETH", decimals: 18, value: "1450000000000000000")
            )
        )
    }
}
