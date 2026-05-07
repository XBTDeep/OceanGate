import Foundation

enum DisplayFormatters {
    static func compactNumber(_ value: Double?) -> String {
        guard let value else { return "N/A" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = value >= 100 ? 0 : 1

        switch abs(value) {
        case 1_000_000...:
            return "\(formatter.string(from: NSNumber(value: value / 1_000_000)) ?? "0")M"
        case 1_000...:
            return "\(formatter.string(from: NSNumber(value: value / 1_000)) ?? "0")K"
        default:
            return formatter.string(from: NSNumber(value: value)) ?? "0"
        }
    }

    static func eth(_ value: Double?) -> String {
        guard let value else { return "N/A" }
        return "\(compactNumber(value)) ETH"
    }
}

