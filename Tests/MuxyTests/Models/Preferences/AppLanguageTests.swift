import Foundation
import Testing

@testable import Muxy

@Suite("App language preference", .serialized)
struct AppLanguageTests {
    private static let suiteName = "app-language-tests"

    private func makeDefaults() -> UserDefaults {
        let defaults = UserDefaults(suiteName: Self.suiteName)!
        defaults.removePersistentDomain(forName: Self.suiteName)
        return defaults
    }

    private func ownDomain(_ defaults: UserDefaults) -> [String: Any] {
        defaults.persistentDomain(forName: Self.suiteName) ?? [:]
    }

    @Test("Applying a concrete language sets AppleLanguages")
    func applyConcreteLanguage() {
        let defaults = makeDefaults()

        AppLanguagePreference.apply(.simplifiedChinese, defaults: defaults)

        let domain = ownDomain(defaults)
        #expect(domain[AppLanguagePreference.storageKey] as? String == "zh-Hans")
        #expect(domain["AppleLanguages"] as? [String] == ["zh-Hans"])
        #expect(AppLanguagePreference.current(defaults: defaults) == .simplifiedChinese)
    }

    @Test("Applying system clears the AppleLanguages override")
    func applySystemClearsOverride() {
        let defaults = makeDefaults()
        AppLanguagePreference.apply(.english, defaults: defaults)

        AppLanguagePreference.apply(.system, defaults: defaults)

        #expect(ownDomain(defaults)["AppleLanguages"] == nil)
        #expect(AppLanguagePreference.current(defaults: defaults) == .system)
    }

    @Test("Missing preference falls back to system")
    func missingPreferenceFallsBack() {
        let defaults = makeDefaults()

        #expect(AppLanguagePreference.current(defaults: defaults) == .system)
    }
}
