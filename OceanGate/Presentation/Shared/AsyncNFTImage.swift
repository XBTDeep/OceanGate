import SwiftUI

struct AsyncNFTImage: View {
    let url: URL?
    var cornerRadius: CGFloat = 22

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .smooth(duration: 0.45))) { phase in
            switch phase {
            case let .success(image):
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.scale(scale: 1.04).combined(with: .opacity))
            case .failure:
                placeholder(symbol: "sparkles")
            case .empty:
                placeholder(symbol: "circle.hexagongrid.fill")
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            @unknown default:
                placeholder(symbol: "questionmark")
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    private func placeholder(symbol: String) -> some View {
        ZStack {
            LinearGradient(colors: NeonTheme.spectrum, startPoint: .topLeading, endPoint: .bottomTrailing)
                .saturation(1.2)
            Image(systemName: symbol)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
        }
    }
}

