import XCTest
@testable import Domain

class CountedSetTests: XCTestCase {
    
    func testInsert() {
        var set = CountedSet<String>()
        set.insert("a")
        set.insert("b")
        set.insert("a")
        
        XCTAssertEqual(set.counts["a"], 2)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testInserting() {
        let set = CountedSet<String>().inserting("a").inserting("b").inserting("a")
        
        XCTAssertEqual(set.counts["a"], 2)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testInsertContentsOfArray() {
        var set = CountedSet<String>()
        set.insert(contentsOf: ["a", "b", "a"])
        
        XCTAssertEqual(set.counts["a"], 2)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testInsertingContentsOfArray() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        
        XCTAssertEqual(set.counts["a"], 2)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testInsertContentsOfSet() {
        var set = CountedSet<String>()
        set.insert(contentsOf: Set(["a", "b", "a"]))
        
        XCTAssertEqual(set.counts["a"], 1)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testInsertingContentsOfSet() {
        let set = CountedSet<String>().inserting(contentsOf: Set(["a", "b", "a"]))
        
        XCTAssertEqual(set.counts["a"], 1)
        XCTAssertEqual(set.counts["b"], 1)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertTrue(set.values.contains("b"))
    }
    
    func testRemove() {
        var set = CountedSet<String>()
        set.insert(contentsOf: ["a", "a"])
        set.remove("a")
        
        XCTAssertEqual(set.counts["a"], 1)
        XCTAssertTrue(set.values.contains("a"))
        
        set.remove("a")
        XCTAssertEqual(set.counts["a"], nil)
        XCTAssertFalse(set.values.contains("a"))
    }
    
    func testRemoving() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "a"])
        let newSet = set.removing("a")
        
        XCTAssertEqual(newSet.counts["a"], 1)
        XCTAssertTrue(newSet.values.contains("a"))
        
        let finalSet = newSet.removing("a")
        XCTAssertEqual(finalSet.counts["a"], nil)
        XCTAssertFalse(finalSet.values.contains("a"))
    }
    
    func testRemoveContentsOfArray() {
        var set = CountedSet<String>()
        set.insert(contentsOf: ["a", "a", "b"])
        set.remove(contentsOf: ["a", "b"])
        
        XCTAssertEqual(set.counts["a"], 1)
        XCTAssertEqual(set.counts["b"], nil)
        XCTAssertTrue(set.values.contains("a"))
        XCTAssertFalse(set.values.contains("b"))
    }
    
    func testRemovingContentsOfArray() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "a", "b"])
        let newSet = set.removing(contentsOf: ["a", "b"])
        
        XCTAssertEqual(newSet.counts["a"], 1)
        XCTAssertEqual(newSet.counts["b"], nil)
        XCTAssertTrue(newSet.values.contains("a"))
        XCTAssertFalse(newSet.values.contains("b"))
    }
    
    func testReduce() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        let result = set.reduce("") { $0 + $1 }
        
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains("a"))
        XCTAssertTrue(result.contains("b"))
    }
    
    func testReduceInto() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        var result = ""
        set.reduce(into: &result) { $0 += $1 }
        
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains("a"))
        XCTAssertTrue(result.contains("b"))
    }
    
    func testFilter() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        let filteredSet = set.filter { $0 != "a" }
        
        XCTAssertEqual(filteredSet.counts["a"], nil)
        XCTAssertEqual(filteredSet.counts["b"], 1)
    }
    
    func testForEach() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        var result = ""
        set.forEach { result += $0 }
        
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.contains("a"))
        XCTAssertTrue(result.contains("b"))
    }
    
    func testMap() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        let mapped = set.map { $0.uppercased() }
        
        XCTAssertEqual(mapped.count, 2)
        XCTAssertTrue(mapped.contains("A"))
        XCTAssertTrue(mapped.contains("B"))
    }
    
    func testCompactMap() {
        let set = CountedSet<String>().inserting(contentsOf: ["a", "b", "a"])
        let compactMapped = set.compactMap { $0 == "b" ? nil : $0.uppercased() }
        
        XCTAssertEqual(compactMapped.count, 1)
        XCTAssertTrue(compactMapped.contains("A"))
    }
}
