import Foundation

enum LocalizationBundle {
    static let current: Bundle = {
        let module = Bundle.module
        let preferred = Bundle.preferredLocalizations(
            from: module.localizations,
            forPreferences: Locale.preferredLanguages
        )
        guard let language = preferred.first,
              let path = module.path(forResource: language, ofType: "lproj"),
              let localized = Bundle(path: path)
        else { return module }
        return localized
    }()
}

extension String {
    var localized: String {
        LocalizationBundle.current.localizedString(forKey: self, value: self, table: nil)
    }

    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
