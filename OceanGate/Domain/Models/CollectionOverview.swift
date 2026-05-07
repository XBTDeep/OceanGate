import Foundation

struct CollectionOverview: Identifiable, Equatable {
    let slug: String
    let name: String
    let description: String
    let imageURL: URL?
    let bannerImageURL: URL?
    let openseaURL: URL?
    let stats: CollectionStats

    var id: String { slug }
}

struct CollectionStats: Equatable {
    let floorPrice: Double?
    let volume: Double?
    let sales: Double?
    let owners: Double?

    static let empty = CollectionStats(floorPrice: nil, volume: nil, sales: nil, owners: nil)
}

struct CollectionTrait: Identifiable, Equatable, Hashable {
    let type: String
    let topValue: String
    let count: Int

    var id: String { "\(type)-\(topValue)" }
}
