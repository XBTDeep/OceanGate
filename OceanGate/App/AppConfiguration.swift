import Foundation

struct AppConfiguration {
    let openSeaAPIKey: String?

    static var live: AppConfiguration {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: "OpenSeaAPIKey") as? String
        let trimmedValue = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines)
        let validValue = trimmedValue.flatMap { value in
            value.isEmpty || value.contains("$(") ? nil : value
        }

        return AppConfiguration(openSeaAPIKey: validValue)
    }
}

