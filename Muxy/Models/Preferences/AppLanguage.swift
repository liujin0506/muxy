import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: "System".localized
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        }
    }
}

enum AppLanguagePreference {
    static let storageKey = "muxy.appLanguage"
    private static let appleLanguagesKey = "AppleLanguages"

    static func current(defaults: UserDefaults = .standard) -> AppLanguage {
        guard let raw = defaults.string(forKey: storageKey),
              let language = AppLanguage(rawValue: raw)
        else { return .system }
        return language
    }

    static func apply(_ language: AppLanguage, defaults: UserDefaults = .standard) {
        defaults.set(language.rawValue, forKey: storageKey)

        guard language != .system else {
            defaults.removeObject(forKey: appleLanguagesKey)
            return
        }

        defaults.set([language.rawValue], forKey: appleLanguagesKey)
    }
}
