//
//  File.swift
//  
//
//  Created by Kevin Kelly on 11/15/24.
//

import Foundation

/// In a binary search that encounters duplicates, specificy whether any index is acceptable, or the first/last index of the duplicates is required.
internal enum BinarySearchOption {
    case any, first, last
}

internal class SortingLogic {
    
    /// Binary search. Assumes that the array is sorted
    public static func binarySearch<T: Comparable>(for element: T, in storage: [T], option: BinarySearchOption = .any) -> (index: Int, exists: Bool) {

        return SortingLogic.binarySearch(
            for: element
            , in: storage
            , equalTo: { $0 == $1 }
            , lessThan: { $0 < $1 }
            , option: option
        )
    }
    
    public static func binarySearch<T>(
        for element: T
        , in storage: [T]
        , equalTo: (T, T) -> Bool
        , lessThan: (T, T) -> Bool
        , option: BinarySearchOption = .any
    ) -> (index: Int, exists: Bool) {
        
        var low = 0
        var high = storage.count - 1
        while low <= high {
            let mid = (low + high) / 2
            
            if equalTo(storage[mid], element) {
                switch option {
                case .any:
                    return (mid, true)
                case .first:
                    high = mid - 1
                case .last:
                    low = mid + 1
                }
            }
            
            else if lessThan(storage[mid], element) {
                low = mid + 1
            }
            
            else {
                high = mid - 1
            }
        }
        return (low, false)
    }
    
//    /// Merges two sorrted arrays. If two elements are eequalm only the new one is added, overwiritng the old value.
//    public static func overwriteMerge<T: Comparable>(_ newSet: [T], into oldSet: [T]) -> [T] {
//        return SortingLogic.internalMerge(newSet, into: oldSet, overwrite: true)
//    }
//    
//    /// Merges two sorrted arrays, keeping all values from each array.
//    public static func merge<T: Comparable>(_ newSet: [T], into oldSet: [T]) -> [T] {
//        return SortingLogic.internalMerge(newSet, into: oldSet, overwrite: false)
//    }
    
    public static func merge<T: Comparable>(_ newSet: [T], into oldSet: [T], overwrite: Bool) -> [T] {
        return SortingLogic.merge(
            newSet
            , into: oldSet
            , lessThan: { $0 < $1 }
            , overwrite: overwrite
        )
    }
    
    public static func merge<T>(
        _ newSet: [T]
        , into oldSet: [T]
        , lessThan: (T, T) -> Bool
        , overwrite: Bool
    ) -> [T] {
        
        var merged: [T] = []
        var oldIndex = 0
        var newIndex = 0
        
        while oldIndex < oldSet.count && newIndex < newSet.count {
            
            if lessThan(oldSet[oldIndex], newSet[newIndex]) {
                merged.append(oldSet[oldIndex])
                oldIndex += 1
            }
            
            else if lessThan(newSet[newIndex], oldSet[oldIndex]) {
                merged.append(newSet[newIndex])
                newIndex += 1
            }
            
            else {
                merged.append(newSet[newIndex])
                if overwrite { oldIndex += 1 }
                newIndex += 1
            }
        }
        
        if oldIndex < oldSet.count {
            merged.append(contentsOf: oldSet.dropFirst(oldIndex))
        }
        
        else if newIndex < newSet.count {
            merged.append(contentsOf: newSet.dropFirst(newIndex))
        }
        
        return merged
    }
}
