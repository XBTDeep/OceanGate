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
}

