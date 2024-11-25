////
////  File.swift
////  
////
////  Created by Kevin Kelly on 11/19/24.
////
//
//import Foundation
//
//public struct IndexSortedSet<Element> {
//    
//    public init(
//        equals: @escaping (Element, Element) -> Bool
//        , lessThen: @escaping (Element, Element) -> Bool
//    ) {
//        self.storage = []
//        self.equals = equals
//        self.lessThen = lessThen
//    }
//    
//    private var storage: [Element] = []
//    private let equals: (Element, Element) -> Bool
//    private let lessThen: (Element, Element) -> Bool
//    
//    public var values: [Element] { storage }
//    public var count: Int { storage.count }
//    
//    public subscript(index: Int) -> Element {
//        return storage[index]
//    }
//    
//    public subscript(element: Element) -> Element? {
//        let result = binarySearch(for: element)
//        if result.exists {
//            return storage[result.index]
//        } else {
//            return nil
//        }
//    }
//    
//    public mutating func insert(_ element: Element) {
//        let result = binarySearch(for: element)
//        if result.exists {
//            storage[result.index] = element
//        } else {
//            storage.insert(element, at: result.index)
//        }
//    }
//    
//    public func inserting(_ element: Element) -> Self {
//        var newSet = self
//        newSet.insert(element)
//        return newSet
//    }
//    
//    public mutating func insert(contentsOf elements: [Element]) {
//        for element in elements {
//            insert(element)
//        }
//    }
//    
//    public func inserting(contentsOf elements: [Element]) -> Self {
//        var newSet = self
//        elements.forEach { element in
//            newSet.insert(element)
//        }
//        return newSet
//    }
//    
//    public mutating func union(_ set: SortedSet<Element>) {
//        overwriteMerge(set: set)
//    }
//    
//    public func unioning(_ set: SortedSet<Element>) -> Self {
//        var newSet = self
//        newSet.overwriteMerge(set: set)
//        return newSet
//    }
//    
//    public mutating func remove(_ element: Element) {
//        let result = binarySearch(for: element)
//        if result.exists {
//            storage.remove(at: result.index)
//        }
//    }
//    
//    public func removing(_ element: Element) -> Self {
//        var newSet = self
//        newSet.remove(element)
//        return newSet
//    }
//    
//    public mutating func remove(contentsOf elements: [Element]) {
//        for element in elements {
//            remove(element)
//        }
//    }
//    
//    public func removing(contentsOf elements: [Element]) -> Self {
//        var newSet = self
//        elements.forEach { element in
//            newSet.remove(element)
//        }
//        return newSet
//    }
//
//    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
//        return storage.reduce(initialResult, nextPartialResult)
//    }
//    
//    public func reduce<Result>(into initialResult: inout Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) {
//        for element in storage {
//            updateAccumulatingResult(&initialResult, element)
//        }
//    }
//    
//    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> Self {
//        var newSet = Self<Element>()
//        for element in storage {
//            if try isIncluded(element) {
//                newSet.storage.append(element)
//            }
//        }
//        return newSet
//    }
//    
//    public func forEach(_ body: (Element) throws -> Void) rethrows {
//        try storage.forEach(body)
//    }
//    
//    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
//        try storage.map(transform)
//    }
//    
//    public func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> [T] {
//        try storage.compactMap(transform)
//    }
//    
//    private func binarySearch(for element: Element) -> (index: Int, exists: Bool) {
//        var low = 0
//        var high = storage.count - 1
//        while low <= high {
//            let mid = (low + high) / 2
//            if Element.isEqual(storage[mid], element) {
//                return (mid, true)
//            } else if Element.compare(storage[mid], element) {
//                low = mid + 1
//            } else {
//                high = mid - 1
//            }
//        }
//        return (low, false)
//    }
//    
//    private mutating func overwriteMerge(set newSet: SortedSet<Element>) {
//        let new = newSet.values
//        var merged: [Element] = []
//        var storageIndex = 0
//        var newIndex = 0
//        
//        while storageIndex < storage.count && newIndex < new.count {
//            if Element.compare(storage[storageIndex], new[newIndex]) {
//                merged.append(storage[storageIndex])
//                storageIndex += 1
//            } else if Element.compare(new[newIndex], storage[storageIndex]) {
//                merged.append(new[newIndex])
//                newIndex += 1
//            } else {
//                merged.append(new[newIndex])
//                storageIndex += 1
//                newIndex += 1
//            }
//        }
//        
//        if storageIndex < storage.count {
//            merged.append(contentsOf: storage.dropFirst(storageIndex))
//        } else if newIndex < new.count {
//            merged.append(contentsOf: new.dropFirst(newIndex))
//        }
//        
//        storage = merged
//    }
//}
