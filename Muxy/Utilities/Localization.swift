import Foundation

extension String {
    var localized: String {
        String(localized: String.LocalizationValue(self), bundle: .module)
    }

    func localized(_ arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
