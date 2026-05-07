import Foundation

struct NFT: Identifiable, Equatable, Hashable {
    let tokenIdentifier: String
    let collectionSlug: String
    let contractAddress: String
    let name: String
    let description: String?
    let imageURL: URL?
    let openseaURL: URL?

    var id: String { "\(contractAddress)-\(tokenIdentifier)" }
}

struct NFTDetail: Equatable {
    let nft: NFT
    let traits: [NFTTrait]
    let owners: [NFTOwner]
    let rarity: NFTRarity?
    let tokenStandard: String?
    let animationURL: URL?
    let metadataURL: URL?
    let bestListing: NFTMarketListing?
}

struct NFTTrait: Identifiable, Equatable, Hashable {
    let type: String
    let value: String
    let displayType: String?
    let maxValue: Double?
    let count: Int?

    var id: String { "\(type)-\(value)" }
}

struct NFTOwner: Identifiable, Equatable, Hashable {
    let address: String
    let quantity: Int?

    var id: String { address }
}

struct NFTRarity: Equatable, Hashable {
    let rank: Int?
    let score: Double?
    let maxRank: Int?
}

struct NFTMarketListing: Equatable, Hashable {
    let orderHash: String?
    let chain: String?
    let marketType: String?
    let price: NFTPrice?
}

struct NFTPrice: Equatable, Hashable {
    let currency: String
    let decimals: Int
    let value: String
}
