//
//  FuzzySearch.swift
//  Domain
//
//  Created by Kevin Kelly on 3/11/25.
//

import Foundation
// Basic implementation of fuzzy string matching in Swift
extension String {
    // Checks if the string contains all characters from the search string in order
    public func fuzzyMatch(_ search: String) -> Bool {
        // Empty search string matches everything
        if search.isEmpty { return true }
        
        // Convert both strings to lowercase for case-insensitive matching
        let selfLowercased = self.lowercased()
        let searchLowercased = search.lowercased()
        
        var searchIndex = searchLowercased.startIndex
        
        // Go through each character in the original string
        for char in selfLowercased {
            // If we find a character matching the current search character
            if char == searchLowercased[searchIndex] {
                // Move to the next search character
                searchIndex = searchLowercased.index(after: searchIndex)
                
                // If we've matched all search characters, return true
                if searchIndex == searchLowercased.endIndex {
                    return true
                }
            }
        }
        
        // If we get here, we didn't find all search characters in order
        return false
    }
    
    // Optional: Add a method that returns a score for the match quality
    public func fuzzyMatchScore(_ search: String) -> Double {
        if search.isEmpty { return 1.0 }
        if self.isEmpty { return 0.0 }
        
        let selfLowercased = self.lowercased()
        let searchLowercased = search.lowercased()
        
        var searchIndex = searchLowercased.startIndex
        var consecutiveMatches = 0
        var totalMatches = 0
        
        for char in selfLowercased {
            if searchIndex < searchLowercased.endIndex && char == searchLowercased[searchIndex] {
                searchIndex = searchLowercased.index(after: searchIndex)
                consecutiveMatches += 1
                totalMatches += 1
            } else {
                consecutiveMatches = 0
            }
        }
        
        // No matches found
        if totalMatches == 0 { return 0.0 }
        
        // Calculate score based on:
        // - How many characters matched
        // - Length ratio between strings
        // - Consecutive matches (bonus)
        let matchRatio = Double(totalMatches) / Double(searchLowercased.count)
        let lengthRatio = Double(min(selfLowercased.count, searchLowercased.count)) / Double(max(selfLowercased.count, searchLowercased.count))
        let consecutiveBonus = Double(consecutiveMatches) / Double(searchLowercased.count) * 0.5
        
        return matchRatio * lengthRatio + consecutiveBonus
    }
}


// Extension to filter arrays of strings
extension Array where Element == String {
    public func fuzzySearch(_ searchText: String) -> [String] {
        if searchText.isEmpty { return self }
        return self.filter { $0.fuzzyMatch(searchText) }
    }
    
    public func fuzzySearchWithScores(_ searchText: String) -> [(string: String, score: Double)] {
        if searchText.isEmpty { return self.map { ($0, 1.0) } }
        
        return self.map { ($0, $0.fuzzyMatchScore(searchText)) }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
    }
}
