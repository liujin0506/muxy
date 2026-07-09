import Foundation
import Testing

@testable import Muxy

@Suite("App language preference")
struct AppLanguageTests {
    private func makeDefaults() -> UserDefaults {
        let suite = "app-language-tests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    @Test("Applying a concrete language sets AppleLanguages")
    func applyConcreteLanguage() {
        let defaults = makeDefaults()

        AppLanguagePreference.apply(.simplifiedChinese, defaults: defaults)

        #expect(defaults.string(forKey: AppLanguagePreference.storageKey) == "zh-Hans")
        #expect(defaults.stringArray(forKey: "AppleLanguages") == ["zh-Hans"])
        #expect(AppLanguagePreference.current(defaults: defaults) == .simplifiedChinese)
    }

    @Test("Applying system clears the AppleLanguages override")
    func applySystemClearsOverride() {
        let defaults = makeDefaults()
        AppLanguagePreference.apply(.english, defaults: defaults)

        AppLanguagePreference.apply(.system, defaults: defaults)

        #expect(defaults.stringArray(forKey: "AppleLanguages") == nil)
        #expect(AppLanguagePreference.current(defaults: defaults) == .system)
    }

    @Test("Missing preference falls back to system")
    func missingPreferenceFallsBack() {
        let defaults = makeDefaults()

        #expect(AppLanguagePreference.current(defaults: defaults) == .system)
    }
}
