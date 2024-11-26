import XCTest
@testable import Assemblages

fileprivate struct TestElement: Comparable {
    static func < (lhs: TestElement, rhs: TestElement) -> Bool {
        lhs.string < rhs.string
    }
    
    static func == (lhs: TestElement, rhs: TestElement) -> Bool {
        lhs.string == rhs.string
    }
    
    var string: String
    var version: Int
}

extension TestElement: Codable {}

class SortedSetTests: XCTestCase {
    
    func testInsert() {
        var set = SortedSet<TestElement>()
        set.insert(TestElement(string: "c", version: 1))
        set.insert(TestElement(string: "a", version: 1))
        set.insert(TestElement(string: "b", version: 1))
        
        set.insert(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[0].version, 2)
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testInserting() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[0].version, 2)
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testInsertContentsOf() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [
            TestElement(string: "d", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "e", version: 1)
            , TestElement(string: "b", version: 2)
        ])
        
        XCTAssertEqual(set[0].string, "b")
        XCTAssertEqual(set[0].version, 2)
        XCTAssertEqual(set[1].string, "d")
        XCTAssertEqual(set[2].string, "e")
    }
    
    func testUnion() {
        var set1 = SortedSet<TestElement>()
        set1.insert(contentsOf: [
            TestElement(string: "a", version: 1)
            , TestElement(string: "c", version: 1)
            , TestElement(string: "d", version: 1)
        ])
        
        var set2 = SortedSet<TestElement>()
        set2.insert(contentsOf: [
            TestElement(string: "a", version: 2)
            , TestElement(string: "b", version: 2)
            , TestElement(string: "d", version: 2)
        ])
        
        set1.union(set2)
        
        XCTAssertEqual(set1[0].string, "a")
        XCTAssertEqual(set1[0].version, 2)
        XCTAssertEqual(set1[1].string, "b")
        XCTAssertEqual(set1[2].string, "c")
        XCTAssertEqual(set1[3].string, "d")
        XCTAssertEqual(set1[3].version, 2)
    }
    
    func testUnioning() {
        let set1 = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "d", version: 1))
        
        let set2 = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 2))
            .inserting(TestElement(string: "b", version: 2))
            .inserting(TestElement(string: "d", version: 2))
        
        let unionSet = set1.unioning(set2)
        
        XCTAssertEqual(unionSet[0].string, "a")
        XCTAssertEqual(unionSet[0].version, 2)
        XCTAssertEqual(unionSet[1].string, "b")
        XCTAssertEqual(unionSet[2].string, "c")
        XCTAssertEqual(unionSet[3].string, "d")
        XCTAssertEqual(unionSet[3].version, 2)
    }
    
    func testRemove() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [
            TestElement(string: "a", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "c", version: 1)
        ])
        
        set.remove(TestElement(string: "b", version: 1))
        
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "c")
    }
    
    func testRemoving() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let newSet = set.removing(TestElement(string: "b", version: 1))
        
        XCTAssertEqual(newSet.count, 2)
        XCTAssertEqual(newSet[0].string, "a")
        XCTAssertEqual(newSet[1].string, "c")
    }
    
    func testRemoveContentsOf() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [
            TestElement(string: "a", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "c", version: 1)
            , TestElement(string: "d", version: 1)
        ])
        set.remove(contentsOf: [
            TestElement(string: "b", version: 1)
            , TestElement(string: "d", version: 1)
        ])
        
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "c")
    }
    
    func testRemovingContentsOf() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "d", version: 1))
        
        let newSet = set.removing(contentsOf: [
            TestElement(string: "b", version: 1)
            , TestElement(string: "d", version: 1)
        ])
        
        XCTAssertEqual(newSet.count, 2)
        XCTAssertEqual(newSet[0].string, "a")
        XCTAssertEqual(newSet[1].string, "c")
    }
    
    func testReduce() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = set.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        set.reduce(into: &result) { $0 += $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let filteredSet = set.filter { $0.string != "b" }
        
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        set.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let mapped = set.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let set = SortedSet<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let compactMapped = set.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
}
