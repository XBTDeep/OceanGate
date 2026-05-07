# Neon Atlas

Neon Atlas is a SwiftUI iOS app that turns live OpenSea collection data into a kinetic discovery surface. It fetches featured collection details, collection stats, and NFT previews from OpenSea API v2, then presents them as animated neon galleries with tappable token detail sheets.

## App Demo:


### Explore Page:

https://github.com/user-attachments/assets/0c91df63-c612-4735-aeae-fd1978deae6d


### Details Page: 

https://github.com/user-attachments/assets/0618313f-9810-4bc0-be28-bd461fdfada9










## Architecture

- Swift + SwiftUI, iOS 17+
- MVVM with `@Observable` view models
- Async/await networking and concurrent collection loading
- SOLID-oriented boundaries:
  - Domain models and service protocol
  - API client for HTTP concerns
  - Repository for DTO-to-domain mapping
  - SwiftUI views focused on presentation

## API Key

The app reads `OPENSEA_API_KEY` from `Config/OpenSea.local.xcconfig`, which is intentionally gitignored. `Config/OpenSea.example.xcconfig` is tracked as a safe template.

For production, do not ship a marketplace API key directly in an app binary. Put the key behind a backend or token-broker service.

## Build

```sh
xcodegen generate
xcodebuild -scheme OceanGate -destination 'generic/platform=iOS Simulator' build
```

