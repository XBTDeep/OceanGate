import Foundation
import Observation

@MainActor
@Observable
final class NFTDetailViewModel {
    private let service: OpenSeaServicing

    let seedNFT: NFT
    var phase: ExploreViewModel.Phase = .idle
    var detail: NFTDetail?

    var displayNFT: NFT {
        detail?.nft ?? seedNFT
    }

    init(nft: NFT, service: OpenSeaServicing) {
        seedNFT = nft
        self.service = service
    }

    func start() async {
        guard phase == .idle else { return }
        await refresh()
    }

    func refresh() async {
        phase = .loading

        do {
            detail = try await service.nftDetail(nft: seedNFT, chain: "ethereum")
            phase = .loaded
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}
