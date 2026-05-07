protocol OpenSeaServicing {
    func collection(slug: String) async throws -> CollectionOverview
    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT]
}

