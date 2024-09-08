//
//  File.swift
//  
//
//  Created by Kevin Kelly on 4/27/24.
//

import Foundation

extension SimpleStore: SimpleStorePublicInterface { }
private protocol SimpleStorePublicInterface {
    associatedtype Model
    
    func save(_ model: Model) async throws
    func load() async throws -> Model?
    func delete() async throws
    
    func sizeAndAllocatedSize() async throws -> (Bytes, Bytes)
    
    func exportData(to root: URL) async throws
    func importData(from root: URL) async throws
}

public final class SimpleStore<Model: Codable> {
    
    private let key: String
    private let namespace: String?
    private let cached: Bool
    private var cachedValue: Model?
    private let discInterface: DiscInterface<Model>
    
    public init(
        key: String
        , cached: Bool
        , namespace: String? = nil
        , inMemory: Bool = false
    ) {
        self.cachedValue = nil
        self.cached = cached
        self.key = key
        self.namespace = namespace
        
        if inMemory {
            discInterface = MemoryDiscInterface<Model>(namespace: namespace)
        } else {
            discInterface = JSONDiscInterface<Model>(namespace: namespace)
        }
    }
    
    public func save(_ model: Model) async throws {
        try await discInterface.save(model, to: key)
        if cached { cachedValue = model }
    }
    
    public func load() async throws -> Model? {
        if let cachedValue = cachedValue { return cachedValue }
        return try await discInterface.load(from: key)
    }
    
    public func delete() async throws {
        try await discInterface.delete(key)
        if cached { cachedValue = nil }
    }
    
    public func sizeAndAllocatedSize() async throws -> (Bytes, Bytes) {
        return try await discInterface.sizeAndAllocatedSize(key)
    }
    
    public func exportData(to root: URL) async throws {
        guard root.hasDirectoryPath else { throw DiscInterfaceError.attemptToExportToFile }
        guard let data = try await discInterface.load(from: key) else { throw DiscInterfaceError.noDataToExport }
        let exportInterface = JSONDiscInterface<Model>(namespace: namespace, root: root)
        try await exportInterface.save(data, to: key)
    }
    
    public func importData(from url: URL) async throws {
        guard url.isFileURL else { throw DiscInterfaceError.attemptToImportFromDir }
        let data = try Data(contentsOf: url)
        let model = try JSONDecoder().decode(Model.self, from: data)
        try await discInterface.save(model, to: key)
    }
}
