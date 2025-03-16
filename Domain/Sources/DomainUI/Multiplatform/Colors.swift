//
//  Colors.swift
//  Domain
//
//  Created by Kevin Kelly on 3/16/25.
//

import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

// Define a platform-agnostic color enum
public enum DomainColor {
    case primary
    case secondary
    case placeholder
    case background
    case accent
    case error
    case success
    case warning
    case link
}

// Extension to SwiftUI.Color to add our domain colors
public extension Color {
    public static func domain(_ colorType: DomainColor) -> Color {
        switch colorType {
        case .primary:
            #if os(iOS)
            return Color(.label)
            #else
            return Color(.labelColor)
            #endif
            
        case .secondary:
            #if os(iOS)
            return Color(.secondaryLabel)
            #else
            return Color(.secondaryLabelColor)
            #endif
            
        case .placeholder:
            #if os(iOS)
            return Color(.placeholderText)
            #else
            return Color(.placeholderTextColor)
            #endif
            
        case .background:
            #if os(iOS)
            return Color(.systemBackground)
            #else
            return Color(.windowBackgroundColor)
            #endif
            
        case .accent:
            #if os(iOS)
            return Color(.systemBlue)
            #else
            return Color(.controlAccentColor)
            #endif
            
        case .error:
            #if os(iOS)
            return Color(.systemRed)
            #else
            return Color(.systemRed)
            #endif
            
        case .success:
            #if os(iOS)
            return Color(.systemGreen)
            #else
            return Color(.systemGreen)
            #endif
            
        case .warning:
            #if os(iOS)
            return Color(.systemYellow)
            #else
            return Color(.systemYellow)
            #endif
            
        case .link:
            #if os(iOS)
            return Color(.link)
            #else
            return Color(.linkColor)
            #endif
        }
    }
}

