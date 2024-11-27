import XCTest
import Assemblages

fileprivate struct TestElement {
    static func lessThan (lhs: TestElement, rhs: TestElement) -> Bool {
        lhs.string < rhs.string
    }
    
    var string: String
    var version: Int
}

extension TestElement: Codable {}

class IndexSortedSetTests: XCTestCase {
    
    func testInsert() {
        var set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
        var set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
    
    func testRemove() {
        var set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let newSet = set.removing(TestElement(string: "b", version: 1))
        
        XCTAssertEqual(newSet.count, 2)
        XCTAssertEqual(newSet[0].string, "a")
        XCTAssertEqual(newSet[1].string, "c")
    }
    
    func testRemoveContentsOf() {
        var set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
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
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = set.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        set.reduce(into: &result) { $0 += $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let filteredSet = set.filter { $0.string != "b" }
        
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        set.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let mapped = set.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let set = IndexSortedSet<TestElement>(lessThan: TestElement.lessThan)
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let compactMapped = set.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
}
