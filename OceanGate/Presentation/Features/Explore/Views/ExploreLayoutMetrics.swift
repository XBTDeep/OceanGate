import SwiftUI

struct ExploreLayoutMetrics {
    let viewportWidth: CGFloat
    let viewportHeight: CGFloat
    let horizontalPadding: CGFloat
    let contentWidth: CGFloat
    let topPadding: CGFloat
    let heroImageHeight: CGFloat
    let statColumns: [GridItem]
    let nftColumns: [GridItem]
    let traitColumns: [GridItem]
    let detailContentWidth: CGFloat
    let detailHorizontalPadding: CGFloat

    init(size: CGSize) {
        viewportWidth = size.width
        viewportHeight = size.height
        horizontalPadding = Self.horizontalPadding(for: size.width)
        contentWidth = max(0, size.width - horizontalPadding * 2)
        topPadding = size.width >= 700 ? 28 : 18
        heroImageHeight = min(size.width >= 700 ? 360 : 230, max(220, contentWidth * 0.38))
        statColumns = Self.columns(count: size.width >= 900 ? 4 : 2, spacing: 10)
        nftColumns = Self.columns(for: contentWidth, minimumWidth: Self.nftMinimumWidth(for: size.width), spacing: 16)
        traitColumns = Self.columns(for: contentWidth, minimumWidth: size.width >= 700 ? 184 : 148, spacing: 10)
        detailHorizontalPadding = Self.horizontalPadding(for: size.width)
        detailContentWidth = max(0, min(size.width - detailHorizontalPadding * 2, 960))
    }

    static func detail(size: CGSize) -> ExploreLayoutMetrics {
        ExploreLayoutMetrics(size: size)
    }

    private static func horizontalPadding(for width: CGFloat) -> CGFloat {
        switch width {
        case 1000...:
            return 48
        case 700..<1000:
            return 32
        default:
            return 20
        }
    }

    private static func nftMinimumWidth(for width: CGFloat) -> CGFloat {
        switch width {
        case 1000...:
            return 190
        case 700..<1000:
            return 172
        default:
            return 150
        }
    }

    private static func columns(for width: CGFloat, minimumWidth: CGFloat, spacing: CGFloat) -> [GridItem] {
        let count = max(1, Int((width + spacing) / (minimumWidth + spacing)))
        return columns(count: count, spacing: spacing)
    }

    private static func columns(count: Int, spacing: CGFloat) -> [GridItem] {
        Array(repeating: GridItem(.flexible(minimum: 0), spacing: spacing), count: count)
    }
}
