import SwiftUI

@main
struct OceanGateApp: App {
    private let repository: OpenSeaRepository

    init() {
        let configuration = AppConfiguration.live
        let client = OpenSeaAPIClient(apiKey: configuration.openSeaAPIKey)
        repository = OpenSeaRepository(client: client)
    }

    var body: some Scene {
        WindowGroup {
            ExploreView(viewModel: ExploreViewModel(service: repository))
                .preferredColorScheme(.dark)
        }
    }
}

