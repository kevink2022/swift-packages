//
//  Codable.swift
//  Domain
//
//  Created by Kevin Kelly on 3/13/25.
//

import Foundation

extension Encodable {
    public func asJsonString() -> String? {
        var encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(self) else { return nil }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
        return jsonString
    }
}

//extension Array where Element: Encodable {
//    public func asJsonString() -> String? {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        guard let jsonData = try? encoder.encode(self) else { return nil }
//        guard let jsonString = String(data: jsonData, encoding: .utf8) else { return nil }
//        return jsonString
//    }
//}
