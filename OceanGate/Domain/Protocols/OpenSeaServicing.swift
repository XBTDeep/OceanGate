protocol OpenSeaServicing {
    func collection(slug: String) async throws -> CollectionOverview
    func collectionTraits(slug: String) async throws -> [CollectionTrait]
    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT]
    func nftDetail(nft: NFT, chain: String) async throws -> NFTDetail
}
