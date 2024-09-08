//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/27/24.
//

import Foundation

public final class JSONDiscInterface<Model: Codable>: DiscInterface<Model> {

    private let namespace: String?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    private let rootDirectory: URL
    
    public init(
        namespace: String? = nil
        , root: URL = URL.applicationSupportDirectory.appending(path: "JSON_storage")
        , encoder: JSONEncoder = JSONEncoder()
        , decoder: JSONDecoder = JSONDecoder()
        , fileManager: FileManager = FileManager()
    ) {
        self.namespace = namespace == nil ? nil : Static.sanitize(namespace ?? "")
        self.rootDirectory = root
        self.encoder = encoder
        self.decoder = decoder
        self.fileManager = fileManager
        
        var baseDirectory = rootDirectory
        
        if let namespace = namespace {
            baseDirectory = baseDirectory.appending(path: namespace)
        }
        
        if fileManager.fileExists(atPath: baseDirectory.path) { return }
        
        do {
           try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
           print("Failed to create directory: \(error.localizedDescription)")
        }
    }
    
    public override func save(_ model: Model, to key: String) async throws {
        let data = try encoder.encode(model)
        let url = pathFor(key)
        try data.write(to: url)
    }
    
    public override func load(from key: String) async throws -> Model? {
        let url = pathFor(key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        let data = try Data.init(contentsOf: url)
        return try decoder.decode(Model.self, from: data)
    }
    
    public override func delete(_ key: String) async throws {
        let url = pathFor(key)
        
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    public override func size(_ key: String) async throws -> Bytes {
        let path = pathFor(key)
        return try path.fileSize()
    }
    
    public override func allocatedSize(_ key: String) async throws -> Bytes {
        let path = pathFor(key)
        return try path.fileSize()
    }
    
    public override func sizeAndAllocatedSize(_ key: String) async throws -> (Bytes, Bytes) {
        let path = pathFor(key)
        
        return (try path.fileSize(), try path.fileAllocatedSize())
    }
    
    private func pathFor(_ key: String) -> URL {
        var url = rootDirectory
        
        if let namespace = namespace {
            url = url.appending(path: namespace)
        }
        
        return url.appending(path: "\(Static.sanitize(key))_\(String(describing: Model.self)).json")
    }
    
    private typealias Static = JSONDiscInterface
    
    private static func sanitize(_ namespace: String) -> String {
        let allowedChars = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_-"))
        let filteredNamespace = namespace.unicodeScalars.filter { allowedChars.contains($0) }.map(String.init).joined()
        let maxLength = 255
        let sanitizedNamespace = String(filteredNamespace.prefix(maxLength))
        return sanitizedNamespace
    }
}
