protocol OpenSeaServicing {
    func collection(slug: String) async throws -> CollectionOverview
    func collectionTraits(slug: String) async throws -> [CollectionTrait]
    func nfts(in collectionSlug: String, limit: Int) async throws -> [NFT]
    func nftsPage(in collectionSlug: String, limit: Int, cursor: String?) async throws -> NFTPage
    func nftDetail(nft: NFT, chain: String) async throws -> NFTDetail
}
