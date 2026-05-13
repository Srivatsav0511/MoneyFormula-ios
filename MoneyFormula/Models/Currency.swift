import Foundation

enum SymbolPosition: String, Codable, Sendable {
    case prefix
    case suffix
}

struct Currency: Identifiable, Hashable, Codable, Sendable {
    var id: String { code }
    let code: String
    let symbol: String
    let name: String
    let localeIdentifier: String
    let symbolPosition: SymbolPosition
    let decimalPlaces: Int

    var locale: Locale { Locale(identifier: localeIdentifier) }
}
