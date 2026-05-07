import Foundation

struct NFT: Identifiable, Equatable {
    let tokenIdentifier: String
    let collectionSlug: String
    let contractAddress: String
    let name: String
    let description: String?
    let imageURL: URL?
    let openseaURL: URL?

    var id: String { "\(contractAddress)-\(tokenIdentifier)" }
}

