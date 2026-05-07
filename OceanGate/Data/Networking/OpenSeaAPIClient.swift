import Foundation

protocol OpenSeaAPIClienting {
    func fetchCollection(slug: String) async throws -> CollectionDTO
    func fetchCollectionStats(slug: String) async throws -> CollectionStatsResponseDTO
    func fetchNFTs(collectionSlug: String, limit: Int) async throws -> NFTListResponseDTO
}

final class OpenSeaAPIClient: OpenSeaAPIClienting {
    private let apiKey: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL = URL(string: "https://api.opensea.io")!

    init(apiKey: String?, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func fetchCollection(slug: String) async throws -> CollectionDTO {
        try await request(path: "/api/v2/collections/\(slug)")
    }

    func fetchCollectionStats(slug: String) async throws -> CollectionStatsResponseDTO {
        try await request(path: "/api/v2/collections/\(slug)/stats")
    }

    func fetchNFTs(collectionSlug: String, limit: Int) async throws -> NFTListResponseDTO {
        var components = URLComponents(url: baseURL.appending(path: "/api/v2/collection/\(collectionSlug)/nfts"), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(min(max(limit, 1), 200))")
        ]

        guard let url = components?.url else {
            throw OpenSeaAPIError.invalidURL
        }

        return try await request(url: url)
    }

    private func request<Response: Decodable>(path: String) async throws -> Response {
        try await request(url: baseURL.appending(path: path))
    }

    private func request<Response: Decodable>(url: URL) async throws -> Response {
        guard let apiKey, !apiKey.isEmpty else {
            throw OpenSeaAPIError.missingAPIKey
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenSeaAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw OpenSeaAPIError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw OpenSeaAPIError.decoding(error)
        }
    }
}

enum OpenSeaAPIError: LocalizedError, Equatable {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)

    static func == (lhs: OpenSeaAPIError, rhs: OpenSeaAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.missingAPIKey, .missingAPIKey), (.invalidURL, .invalidURL), (.invalidResponse, .invalidResponse):
            true
        case let (.httpStatus(lhsCode), .httpStatus(rhsCode)):
            lhsCode == rhsCode
        case (.decoding, .decoding):
            true
        default:
            false
        }
    }

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            "OpenSea API key is missing. Add it to Config/OpenSea.local.xcconfig."
        case .invalidURL:
            "The OpenSea request URL could not be built."
        case .invalidResponse:
            "OpenSea returned an invalid response."
        case let .httpStatus(code):
            "OpenSea returned HTTP \(code)."
        case let .decoding(error):
            "OpenSea data could not be decoded: \(error.localizedDescription)"
        }
    }
}

