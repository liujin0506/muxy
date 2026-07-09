import Foundation
import Testing

@testable import Muxy

@Suite("Localization")
struct LocalizationTests {
    private func lprojBundle(matching language: String) throws -> Bundle {
        let localizations = Bundle.module.localizations
        let match = try #require(
            localizations.first { $0.caseInsensitiveCompare(language) == .orderedSame },
            Comment(rawValue: "available localizations: \(localizations)")
        )
        let path = try #require(Bundle.module.path(forResource: match, ofType: "lproj"))
        return try #require(Bundle(path: path))
    }

    @Test("Simplified Chinese strings are bundled and resolve")
    func simplifiedChineseResolves() throws {
        let bundle = try lprojBundle(matching: "zh-Hans")

        #expect(bundle.localizedString(forKey: "Layout", value: "missing", table: nil) == "布局")
        #expect(bundle.localizedString(forKey: "Show Status Bar", value: "missing", table: nil) == "显示状态栏")
        #expect(bundle.localizedString(forKey: "Built-in", value: "missing", table: nil) == "内置")
        #expect(bundle.localizedString(forKey: "Display Language", value: "missing", table: nil) == "显示语言")
    }

    @Test("English base strings are bundled and resolve")
    func englishBaseResolves() throws {
        let bundle = try lprojBundle(matching: "en")

        #expect(bundle.localizedString(forKey: "Layout", value: "missing", table: nil) == "Layout")
    }

    @Test("A Chinese preference resolves to the bundled Chinese localization")
    func chinesePreferenceMatchesBundledLocalization() {
        let preferred = Bundle.preferredLocalizations(
            from: Bundle.module.localizations,
            forPreferences: ["zh-Hans"]
        )

        #expect(preferred.first?.caseInsensitiveCompare("zh-Hans") == .orderedSame)
    }

    @Test("Unknown keys fall back to the key itself")
    func unknownKeyFallsBack() {
        #expect("A key that does not exist".localized == "A key that does not exist")
    }
}
