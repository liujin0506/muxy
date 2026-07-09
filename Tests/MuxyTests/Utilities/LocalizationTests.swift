import Foundation
import Testing

@testable import Muxy

@Suite("Localization")
struct LocalizationTests {
    @Test("Simplified Chinese strings are bundled and resolve")
    func simplifiedChineseResolves() throws {
        let contents = (try? FileManager.default.subpathsOfDirectory(atPath: Bundle.module.bundleURL.path)) ?? []
        let diagnostics = "bundle contents: \(contents.sorted())"

        let path = try #require(Bundle.module.path(forResource: "zh-Hans", ofType: "lproj"), Comment(rawValue: diagnostics))
        let bundle = try #require(Bundle(path: path))

        #expect(bundle.localizedString(forKey: "Layout", value: "missing", table: nil) == "布局")
        #expect(bundle.localizedString(forKey: "Show Status Bar", value: "missing", table: nil) == "显示状态栏")
        #expect(bundle.localizedString(forKey: "Built-in", value: "missing", table: nil) == "内置")
    }

    @Test("English base strings are bundled and resolve")
    func englishBaseResolves() throws {
        let path = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))

        #expect(bundle.localizedString(forKey: "Layout", value: "missing", table: nil) == "Layout")
    }

    @Test("Unknown keys fall back to the key itself")
    func unknownKeyFallsBack() {
        #expect("A key that does not exist".localized == "A key that does not exist")
    }
}
