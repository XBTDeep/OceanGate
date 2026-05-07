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

    static func price(_ price: NFTPrice?) -> String {
        guard let price, let rawValue = Decimal(string: price.value) else {
            return "Not listed"
        }

        let normalizedValue = rawValue / decimalPower(of: price.decimals)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = normalizedValue < 1 ? 4 : 3
        formatter.minimumFractionDigits = 0

        let amount = formatter.string(from: normalizedValue as NSDecimalNumber) ?? "\(normalizedValue)"
        return "\(amount) \(price.currency)"
    }

    static func compactAddress(_ address: String) -> String {
        guard address.count > 12 else { return address }
        return "\(address.prefix(6))...\(address.suffix(4))"
    }

    static func rarity(_ value: Double?) -> String {
        guard let value else { return "N/A" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "N/A"
    }

    private static func decimalPower(of exponent: Int) -> Decimal {
        guard exponent > 0 else { return 1 }
        return (0..<exponent).reduce(Decimal(1)) { result, _ in
            result * Decimal(10)
        }
    }
}
