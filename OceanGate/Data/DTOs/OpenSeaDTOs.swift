import Foundation

struct CollectionDTO: Decodable {
    let collection: String?
    let name: String?
    let description: String?
    let imageUrl: String?
    let bannerImageUrl: String?
    let openseaUrl: String?
}

struct CollectionStatsResponseDTO: Decodable {
    let total: CollectionStatsDTO?
}

struct CollectionStatsDTO: Decodable {
    let floorPrice: Double?
    let volume: Double?
    let sales: Double?
    let numOwners: Double?
}

struct NFTListResponseDTO: Decodable {
    let nfts: [NFTDTO]
    let next: String?
}

struct NFTDTO: Decodable {
    let identifier: String?
    let collection: String?
    let contract: String?
    let name: String?
    let description: String?
    let imageUrl: String?
    let openseaUrl: String?
}

