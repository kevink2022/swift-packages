//
//  File.swift
//  
//
//  Created by Kevin Kelly on 6/9/24.
//

import Foundation

public struct AppPath: Codable, Equatable, Hashable {
    public let relative: String
    
    private static let root: URL = URL.homeDirectory
    
    public init(relativePath: String) {
        self.relative = relativePath
    }
    
    public init(url: URL) {
        let absolutePath = String(url.path(percentEncoded: false).dropFirst("/private".count))
        let rootPath = AppPath.root.path(percentEncoded: false)
        
        if absolutePath.hasPrefix(rootPath) {
            self.relative = String(absolutePath.dropFirst(rootPath.count))
        } else {
            self.relative = ""
        }
    }
    
    public var url: URL {
        return AppPath.root.appending(path: self.relative)
    }
}
