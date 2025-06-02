import XCTest
import Assemblages

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


class SortedArrayTests: XCTestCase {
    
    func testInsert() {
        var array = SortedArray<TestElement>()
        array.insert(TestElement(string: "c", version: 1))
        array.insert(TestElement(string: "a", version: 1))
        array.insert(TestElement(string: "b", version: 1))
        
        array.insert(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(array[0].string, "a")
        XCTAssertEqual(array[1].string, "a")
        XCTAssertEqual(array[2].string, "b")
        XCTAssertEqual(array[3].string, "c")
    }
    
    func testInserting() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "a", version: 2))
        
        XCTAssertEqual(array[0].string, "a")
        XCTAssertEqual(array[1].string, "a")
        XCTAssertEqual(array[2].string, "b")
        XCTAssertEqual(array[3].string, "c")
    }
    
    func testInsertContentsOf() {
        var array = SortedArray<TestElement>()
        array.insert([
            TestElement(string: "d", version: 1)
            , TestElement(string: "b", version: 1)
            , TestElement(string: "e", version: 1)
            , TestElement(string: "b", version: 2)
        ])
        
        XCTAssertEqual(array[0].string, "b")
        XCTAssertEqual(array[1].string, "b")
        XCTAssertEqual(array[2].string, "d")
        XCTAssertEqual(array[3].string, "e")
    }
    
    func testMerge() {
        var array1 = SortedArray<TestElement>()
        array1.insert([
            TestElement(string: "a", version: 1)
            , TestElement(string: "c", version: 1)
            , TestElement(string: "d", version: 1)
        ])
        
        var array2 = SortedArray<TestElement>()
        array2.insert([
            TestElement(string: "a", version: 2)
            , TestElement(string: "b", version: 2)
            , TestElement(string: "d", version: 2)
        ])
        
        array1.merge(with: array2)
        
        XCTAssertEqual(array1[0].string, "a")
        XCTAssertEqual(array1[1].string, "a")
        XCTAssertEqual(array1[2].string, "b")
        XCTAssertEqual(array1[3].string, "c")
        XCTAssertEqual(array1[4].string, "d")
        XCTAssertEqual(array1[5].string, "d")
    }
    
    func testMerging() {
        let array1 = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "c", version: 1))
            .inserting(TestElement(string: "d", version: 1))
        
        let array2 = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 2))
            .inserting(TestElement(string: "b", version: 2))
            .inserting(TestElement(string: "d", version: 2))
        
        let mergedArray = array1.merging(with: array2)
        
        XCTAssertEqual(mergedArray[0].string, "a")
        XCTAssertEqual(mergedArray[1].string, "a")
        XCTAssertEqual(mergedArray[2].string, "b")
        XCTAssertEqual(mergedArray[3].string, "c")
        XCTAssertEqual(mergedArray[4].string, "d")
        XCTAssertEqual(mergedArray[5].string, "d")
    }
    
    func testReduce() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = array.reduce("") { $0 + $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testReduceInto() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let result = array.reduce(into: "") { $0 += $1.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testFilter() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let filteredSet = array.filter { $0.string != "b" }
        
        XCTAssertEqual(filteredSet.count, 2)
        XCTAssertEqual(filteredSet[0].string, "a")
        XCTAssertEqual(filteredSet[1].string, "c")
    }
    
    func testForEach() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        var result = ""
        array.forEach { result += $0.string }
        
        XCTAssertEqual(result, "abc")
    }
    
    func testMap() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let mapped = array.map { $0.string.uppercased() }
        
        XCTAssertEqual(mapped, ["A", "B", "C"])
    }
    
    func testCompactMap() {
        let array = SortedArray<TestElement>()
            .inserting(TestElement(string: "a", version: 1))
            .inserting(TestElement(string: "b", version: 1))
            .inserting(TestElement(string: "c", version: 1))
        
        let compactMapped = array.compactMap { $0.string == "b" ? nil : $0.string.uppercased() }
        
        XCTAssertEqual(compactMapped, ["A", "C"])
    }
    
    func testEncodeDecodeIntSet() throws {
        let array = [5, 2, 8, 1, 3]
        let arraySorted = [1, 2, 3, 5, 8]
        let originalSorted = SortedArray(array)
        
        let sortedData = try JSONEncoder().encode(originalSorted)
        let arrayData = try JSONEncoder().encode(array)
        
        let decodedArrayFromSorted = try JSONDecoder().decode([Int].self, from: sortedData)
        let decodedSortedFromArray = try JSONDecoder().decode(SortedSet<Int>.self, from: arrayData)
        let decodedSortedFromSorted = try JSONDecoder().decode(SortedSet<Int>.self, from: sortedData)

        XCTAssertEqual(decodedArrayFromSorted, arraySorted)
        XCTAssertEqual(decodedSortedFromArray.values, arraySorted)
        XCTAssertEqual(decodedSortedFromSorted.values, arraySorted)
    }
}
