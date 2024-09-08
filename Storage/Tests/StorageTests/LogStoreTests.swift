import XCTest
@testable import Storage

private class TestLog: Loggable {
    public let id: UUID
    public let timestamp: Date
    public let body: String
    
    init(
        _ body: String
        , id: UUID = UUID()
        , timestamp: Date = Date.now
    ) {
        self.id = id
        self.timestamp = timestamp
        self.body = body
    }
}

final class LogStoreTests: XCTestCase {
    
    private func initSut(key: String, cached: Bool = true, namespace: String? = nil) -> LogStore<TestLog> {
        return LogStore(key: key, cached: cached, namespace: namespace, inMemory: true)
    }
    
    func wipeStorage() async {
        await MemoryDisc.shared.wipe()
    }
    
    override func setUp() async throws {
        await wipeStorage()
        try await super.setUp()
    }
    
    deinit {
        Task { await wipeStorage() }
    }
       
    private let beforeTimestamp = Date.now
    private let log1 = TestLog("log1")
    private let log2 = TestLog("log2")
    private let log3 = TestLog("log3")
    private let log4 = TestLog("log4")
    
    func test_saveAndLoad() async {
      
        do {
            let sut = initSut(key: "test_logs_1")
            
            try await sut.save(log1)
            try await sut.save(log2)
            
            let halfLogs = try await sut.load()
            XCTAssertEqual(halfLogs.count, 2)
            XCTAssertEqual(halfLogs[0].id, log2.id)
            XCTAssertEqual(halfLogs[1].id, log1.id)
            
            try await sut.save(log3)
            try await sut.save(log4)
            
            let allLogs = try await sut.load()
            XCTAssertEqual(allLogs.count, 4)
            XCTAssertEqual(allLogs[0].id, log4.id)
            XCTAssertEqual(allLogs[1].id, log3.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_load_countLogs() async {

        do {
            let sut = initSut(key: "test_logs_2")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let twoLogs = try await sut.load(last: 2)
            XCTAssertEqual(twoLogs.count, 2)
            XCTAssertEqual(twoLogs[0].id, log4.id)
            XCTAssertEqual(twoLogs[1].id, log3.id)
            
            let threeLogs = try await sut.load(last: 3)
            XCTAssertEqual(threeLogs.count, 3)
            XCTAssertEqual(threeLogs[2].id, log2.id)
            
            let fiveLogs = try await sut.load(last: 5)
            XCTAssertEqual(fiveLogs.count, 4)
            XCTAssertEqual(fiveLogs[3].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
   
    func test_load_logsSinceID() async {
        
        do {
            let sut = initSut(key: "test_logs_3")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let twoLogs = try await sut.load(from: log3.id)
            XCTAssertEqual(twoLogs.count, 2)
            XCTAssertEqual(twoLogs[0].id, log4.id)
            XCTAssertEqual(twoLogs[1].id, log3.id)
            
            let threeLogs = try await sut.load(from: log1.id)
            XCTAssertEqual(threeLogs.count, 4)
            XCTAssertEqual(threeLogs[3].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_load_logsSinceTime() async {
        let anchor = Date.now
        
        let before = anchor.addingTimeInterval(-6)
        let log1 = TestLog("log1", timestamp: anchor.addingTimeInterval(-5))
        let log2 = TestLog("log2", timestamp: anchor.addingTimeInterval(-4))
        let middle = anchor.addingTimeInterval(-3)
        let log3 = TestLog("log3", timestamp: anchor.addingTimeInterval(-2))
        let log4 = TestLog("log4", timestamp: anchor.addingTimeInterval(-1))
        let after = anchor
        
        do {
            let sut = initSut(key: "test_logs_4")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let allLogs = try await sut.load()
            XCTAssertEqual(allLogs.count, 4)
            
            let beforeLogs = try await sut.load(since: before)
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            let middleLogs = try await sut.load(since: middle)
            XCTAssertEqual(middleLogs.count, 2)
            XCTAssertEqual(middleLogs[1].id, log3.id)
            
            let afterLogs = try await sut.load(since: after)
            XCTAssertEqual(afterLogs.count, 0)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete_allLogs() async {
       
        do {
            let sut = initSut(key: "test_logs_5")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let beforeLogs = try await sut.load()
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            try await sut.delete()
            
            let afterLogs = try await sut.load()
            XCTAssertEqual(afterLogs.count, 0)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete_countLogs() async {
       
        do {
            let sut = initSut(key: "test_logs_6")

            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let beforeLogs = try await sut.load()
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            try await sut.delete(last: 2)
            
            let afterLogs = try await sut.load()
            XCTAssertEqual(afterLogs.count, 2)
            XCTAssertEqual(afterLogs[0].id, log2.id)
            XCTAssertEqual(afterLogs[1].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete_logsIncludingID() async {
        
        do {
            let sut = initSut(key: "test_logs_7")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let beforeLogs = try await sut.load()
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            try await sut.delete(including: log3.id)
            
            let afterLogs = try await sut.load()
            XCTAssertEqual(afterLogs.count, 2)
            XCTAssertEqual(afterLogs[0].id, log2.id)
            XCTAssertEqual(afterLogs[1].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete_logsAfterID() async {
        
        do {
            let sut = initSut(key: "test_logs_7")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let beforeLogs = try await sut.load()
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            try await sut.delete(after: log2.id)
            
            let afterLogs = try await sut.load()
            XCTAssertEqual(afterLogs.count, 2)
            XCTAssertEqual(afterLogs[0].id, log2.id)
            XCTAssertEqual(afterLogs[1].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
    
    func test_delete_logsSinceTime() async {
        let anchor = Date.now
        
        let log1 = TestLog("log1", timestamp: anchor.addingTimeInterval(-5))
        let log2 = TestLog("log2", timestamp: anchor.addingTimeInterval(-4))
        let middle = anchor.addingTimeInterval(-3)
        let log3 = TestLog("log3", timestamp: anchor.addingTimeInterval(-2))
        let log4 = TestLog("log4", timestamp: anchor.addingTimeInterval(-1))
                
        do {
            let sut = initSut(key: "test_logs_8")
            
            try await sut.save(log1)
            try await sut.save(log2)
            try await sut.save(log3)
            try await sut.save(log4)
            
            let beforeLogs = try await sut.load()
            XCTAssertEqual(beforeLogs.count, 4)
            XCTAssertEqual(beforeLogs[3].id, log1.id)
            
            try await sut.delete(since: middle)
            
            let afterLogs = try await sut.load()
            XCTAssertEqual(afterLogs.count, 2)
            XCTAssertEqual(afterLogs[0].id, log2.id)
            XCTAssertEqual(afterLogs[1].id, log1.id)
            
        } catch {
            XCTFail("Error: \(error.localizedDescription)")
        }
    }
}
