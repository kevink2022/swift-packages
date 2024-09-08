//
//  File.swift
//  
//
//  Created by Kevin Kelly on 5/16/24.
//

import Foundation
import Domain

public enum FileInterfaceError: LocalizedError, Equatable {
    case enumeratorInitFail(URL)
    
    public var errorDescription: String? {
        switch self {
        case .enumeratorInitFail(let url): return "An enumerator could not be initialized at the library URL: \(url)"
        }
    }
    
    public static func == (lhs: FileInterfaceError, rhs: FileInterfaceError) -> Bool {
        switch (lhs, rhs) {
        case (.enumeratorInitFail(let lhs), .enumeratorInitFail(let rhs)):
            return String(describing: lhs) == String(describing: rhs)
        }
    }
}

public class FileInterface {
    
    private let root: URL
    private let fileManager: FileManager
    
    public init (
        at root: URL
        , fileManager: FileManager = FileManager()
    ) {
        self.root = root
        self.fileManager = fileManager
    }
    
    public func allFiles(of extensions: Set<String>? = nil) throws -> [URL] {
        let allURLs = try allFiles()
        let allExtensionURLs = filterExtensions(include: extensions, in: allURLs)
        return allExtensionURLs
    }
    
    public func allFiles(of extensions: Set<String>? = nil, excluding: Set<URL>? = nil) throws -> [URL] {
        let allURLs = try allFiles()
        let allExtensionURLs = filterExtensions(include: extensions, in: allURLs)
        let allNewURLs = filterExcludedURLs(exclude: excluding, from: allExtensionURLs)
        return allNewURLs
    }
    
    public func allFiles(of extensions: Set<String>? = nil, excluding: Set<AppPath>? = nil) throws -> [URL] {
        let allURLs = try allFiles()
        let allExtensionURLs = filterExtensions(include: extensions, in: allURLs)
        let allNewURLs = filterExcludedAppPaths(exclude: excluding, from: allExtensionURLs)
        return allNewURLs
    }
    
    private func allFiles() throws -> [URL] {
        guard let enumerator = fileManager.enumerator(at: root, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        else { throw FileInterfaceError.enumeratorInitFail(root) }
        
        return enumerator.allObjects.compactMap { $0 as? URL }
    }
    
    private func filterExtensions(include extensions: Set<String>?, in urls: [URL]) -> [URL] {
        return urls.filter { extensions?.contains($0.pathExtension.lowercased()) ?? true }
    }
    
    private func filterExcludedURLs(exclude excludeURLs: Set<URL>?, from URLs: [URL]) -> [URL] {
        if let excludeURLs = excludeURLs, excludeURLs.count > 1 {
            return URLs.filter{ !excludeURLs.contains($0) }
        } else {
            return URLs
        }
    }
    
    private func filterExcludedAppPaths(exclude excludeURLs: Set<AppPath>?, from URLs: [URL]) -> [URL] {
        if let excludeURLs = excludeURLs, excludeURLs.count > 1 {
            return URLs.filter{ !excludeURLs.contains(AppPath(url: $0)) }
        } else {
            return URLs
        }
    }
    
    private func filterExcludedAppPaths() {}
    
    public func size() throws -> Bytes {
        let urls = try allFiles()
        return try urls.reduce(0) { partialResult, url in
            let fileSize = try url.fileSize()
            return partialResult + fileSize
        }
    }
    
    public func allocatedSize() throws -> Bytes {
        let urls = try allFiles()
        return try urls.reduce(0) { partialResult, url in
            let fileAllocatedSize = try url.fileAllocatedSize()
            return partialResult + fileAllocatedSize
        }
    }
    
    public func sizeAndAllocatedSize() throws -> (Bytes, Bytes) {
        return (try self.size(), try self.allocatedSize())
    }
}
