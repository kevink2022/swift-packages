import XCTest
@testable import Storage

class DiscInterfaceTests: XCTestCase {
    
    func initSut(namespace: String? = nil) -> DiscInterface<String> {
        return MemoryDiscInterface<String>(namespace: namespace)
    }
    
    func wipeStorage() async {
        await MemoryDisc.shared.wipe()
    }

    let namespace = "test_namespace"
    let namespaceA = "test_namespaceA"
    let namespaceB = "test_namespaceB"
    
    override func setUp() async throws {
        await wipeStorage()
        try await super.setUp()
    }
    
    deinit {
        Task { await wipeStorage() }
    }
    
    func test_saveAndLoad() async throws {
        let value = "value_1"
        let key = "key_1"
        
        do {
            let sut = initSut(namespace: namespace)
            try await sut.save(value, to: key)
            let loaded = try await sut.load(from: key)
            XCTAssertEqual(value, loaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_saveOverwriteLoad() async throws {
        let value = "value_2"
        let overwriteValue = "overwrite_2"
        let key = "key_2"
        
        do {
            let sut = initSut(namespace: namespace)
            try await sut.save(value, to: key)
            let loaded = try await sut.load(from: key)
            XCTAssertEqual(value, loaded)

            try await sut.save(overwriteValue, to: key)
            let overwriteLoaded = try await sut.load(from: key)
            XCTAssertEqual(overwriteValue, overwriteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_saveReinitLoad() async throws {
        let value = "value_3"
        let key = "key_3"
        
        do {
            let sut = initSut(namespace: namespace)
            try await sut.save(value, to: key)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
        
        do {
            let sut = initSut(namespace: namespace)
            let loaded = try await sut.load(from: key)
            XCTAssertEqual(value, loaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_namespaces() async throws {
        let valueA = "value_4A"
        let valueB = "value_4B"
        let key = "key_4"
        
        do {
            let sutA = initSut(namespace: namespaceA)
            let sutB = initSut(namespace: namespaceB)
            
            try await sutA.save(valueA, to: key)
            
            let loadA1 = try await sutA.load(from: key)
            let loadB1 = try await sutB.load(from: key)
            XCTAssertEqual(valueA, loadA1)
            XCTAssertEqual(nil, loadB1)

            try await sutB.save(valueB, to: key)
            
            let loadA2 = try await sutA.load(from: key)
            let loadB2 = try await sutB.load(from: key)
            XCTAssertEqual(valueA, loadA2)
            XCTAssertEqual(valueB, loadB2)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete() async throws {
        let value = "value_5"
        let key = "key_5"
        
        do {
            let sut = initSut(namespace: namespace)
            try await sut.save(value, to: key)
            let loaded = try await sut.load(from: key)
            XCTAssertEqual(value, loaded)

            try await sut.delete(key)
            let deleteLoaded = try await sut.load(from: key)
            XCTAssertEqual(nil, deleteLoaded)
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
}
