import XCTest
@testable import Domain

struct TestElement: SetSortable {
    var string: String
    
    static func compare(_ a: TestElement, _ b: TestElement) -> Bool {
        return a.string < b.string
    }
    
    static func isEqual(_ a: TestElement, _ b: TestElement) -> Bool {
        return a.string == b.string
    }
}

extension TestElement: Codable {}

class SortedSetTests: XCTestCase {
    
    func testInsert() {
        var set = SortedSet<TestElement>()
        set.insert(TestElement(string: "c"))
        set.insert(TestElement(string: "a"))
        set.insert(TestElement(string: "b"))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testInserting() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "c")).inserting(TestElement(string: "a")).inserting(TestElement(string: "b"))
        
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "b")
        XCTAssertEqual(set[2].string, "c")
    }
    
    func testInsertContentsOf() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [TestElement(string: "d"), TestElement(string: "b"), TestElement(string: "e")])
        
        XCTAssertEqual(set[0].string, "b")
        XCTAssertEqual(set[1].string, "d")
        XCTAssertEqual(set[2].string, "e")
    }
    
    func testUnion() {
        var set1 = SortedSet<TestElement>()
        set1.insert(contentsOf: [TestElement(string: "a"), TestElement(string: "c")])
        
        var set2 = SortedSet<TestElement>()
        set2.insert(contentsOf: [TestElement(string: "b"), TestElement(string: "d")])
        
        set1.union(set2)
        
        XCTAssertEqual(set1[0].string, "a")
        XCTAssertEqual(set1[1].string, "b")
        XCTAssertEqual(set1[2].string, "c")
        XCTAssertEqual(set1[3].string, "d")
    }
    
    func testUnioning() {
        let set1 = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "c"))
        let set2 = SortedSet<TestElement>().inserting(TestElement(string: "b")).inserting(TestElement(string: "d"))
        
        let unionSet = set1.unioning(set2)
        
        XCTAssertEqual(unionSet[0].string, "a")
        XCTAssertEqual(unionSet[1].string, "b")
        XCTAssertEqual(unionSet[2].string, "c")
        XCTAssertEqual(unionSet[3].string, "d")
    }
    
    func testRemove() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [TestElement(string: "a"), TestElement(string: "b"), TestElement(string: "c")])
        set.remove(TestElement(string: "b"))
        
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "c")
    }
    
    func testRemoving() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        let newSet = set.removing(TestElement(string: "b"))
        
        XCTAssertEqual(newSet.count, 2)
        XCTAssertEqual(newSet[0].string, "a")
        XCTAssertEqual(newSet[1].string, "c")
    }
    
    func testRemoveContentsOf() {
        var set = SortedSet<TestElement>()
        set.insert(contentsOf: [TestElement(string: "a"), TestElement(string: "b"), TestElement(string: "c"), TestElement(string: "d")])
        set.remove(contentsOf: [TestElement(string: "b"), TestElement(string: "d")])
        
        XCTAssertEqual(set.count, 2)
        XCTAssertEqual(set[0].string, "a")
        XCTAssertEqual(set[1].string, "c")
    }
    
    func testRemovingContentsOf() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c")).inserting(TestElement(string: "d"))
        let newSet = set.removing(contentsOf: [TestElement(string: "b"), TestElement(string: "d")])
        
        XCTAssertEqual(newSet.count, 2)
        XCTAssertEqual(newSet[0].string, "a")
        XCTAssertEqual(newSet[1].string, "c")
    }
    
    func testReduce() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        let result = set.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        var result = ""
        set.reduce(into: &result) { $0 += $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        let filteredSet = set.filter { $0.string != "b" }
        
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        var result = ""
        set.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        let mapped = set.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let set = SortedSet<TestElement>().inserting(TestElement(string: "a")).inserting(TestElement(string: "b")).inserting(TestElement(string: "c"))
        let compactMapped = set.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
}
