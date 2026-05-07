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

struct CollectionTraitsResponseDTO: Decodable {
    let traits: [String: CollectionTraitCategoryDTO]
}

struct CollectionTraitCategoryDTO: Decodable {
    let values: [String: Int]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let values = try? container.decode([String: Int].self) {
            self.values = values
            return
        }

        if let values = try? container.decode([String: Double].self) {
            self.values = values.mapValues { Int($0) }
            return
        }

        let keyedContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
        if let nestedValues = try? keyedContainer.decode([String: Int].self, forKey: DynamicCodingKey(stringValue: "values")) {
            values = nestedValues
            return
        }

        if let nestedValues = try? keyedContainer.decode([String: Double].self, forKey: DynamicCodingKey(stringValue: "values")) {
            values = nestedValues.mapValues { Int($0) }
            return
        }

        values = [:]
    }
}

struct NFTListResponseDTO: Decodable {
    let nfts: [NFTDTO]
    let next: String?
}

struct NFTDetailResponseDTO: Decodable {
    let nft: NFTDTO
}

struct NFTDTO: Decodable {
    let identifier: String?
    let collection: String?
    let contract: String?
    let name: String?
    let description: String?
    let imageUrl: String?
    let openseaUrl: String?
    let animationUrl: String?
    let metadataUrl: String?
    let tokenStandard: String?
    let traits: [NFTTraitDTO]?
    let owners: [NFTOwnerDTO]?
    let rarity: NFTRarityDTO?
    let creator: String?
}

struct NFTTraitDTO: Decodable {
    let traitType: String?
    let value: NFTTraitValueDTO?
    let displayType: String?
    let maxValue: Double?
    let traitCount: Int?
}

enum NFTTraitValueDTO: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else {
            self = .string("")
        }
    }

    var displayValue: String {
        switch self {
        case let .string(value):
            value
        case let .number(value):
            value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
        case let .bool(value):
            value ? "True" : "False"
        }
    }
}

struct NFTOwnerDTO: Decodable {
    let address: String?
    let quantity: Int?
}

struct NFTRarityDTO: Decodable {
    let rank: Int?
    let score: Double?
    let maxRank: Int?
}

struct BestListingDTO: Decodable {
    let orderHash: String?
    let chain: String?
    let type: String?
    let price: ListingPriceContainerDTO?
}

struct ListingPriceContainerDTO: Decodable {
    let current: ListingPriceDTO?
}

struct ListingPriceDTO: Decodable {
    let currency: String?
    let decimals: Int?
    let value: String?
}

struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
