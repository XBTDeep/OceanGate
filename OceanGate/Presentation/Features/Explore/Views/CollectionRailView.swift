import SwiftUI

struct CollectionRailView: View {
    let collections: [CollectionOverview]
    let selectedSlug: String
    let namespace: Namespace.ID
    let width: CGFloat
    let onSelect: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(collections) { collection in
                    Button {
                        onSelect(collection.slug)
                    } label: {
                        CollectionRailCard(
                            collection: collection,
                            isSelected: selectedSlug == collection.slug,
                            namespace: namespace
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 0)
        }
        .scrollClipDisabled()
        .frame(width: width, alignment: .leading)
    }
}

private struct CollectionRailCard: View {
    let collection: CollectionOverview
    let isSelected: Bool
    let namespace: Namespace.ID

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncNFTImage(url: collection.imageURL, cornerRadius: 18)
                .frame(width: 84, height: 84)

            Text(collection.name)
                .font(.caption.weight(.black))
                .foregroundStyle(.white)
                .lineLimit(2)
                .frame(width: 104, alignment: .leading)
        }
        .padding(10)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [NeonTheme.cobalt.opacity(0.34), NeonTheme.coral.opacity(0.28)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .matchedGeometryEffect(id: "selectedCollection", in: namespace)
            } else {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(NeonTheme.glass)
            }
        }
    }
}
