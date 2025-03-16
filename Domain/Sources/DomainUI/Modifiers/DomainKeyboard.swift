//
//  Modifiers.swift
//  Domain
//
//  Created by Kevin Kelly on 3/16/25.
//

import SwiftUI

/// Platform-agnostic keyboard type enum
public enum DomainKeyboardType {
    case `default`
    case emailAddress
    case numberPad
    case phonePad
    case URL
    case decimalPad
    case twitter
    case webSearch
    case password
    
    #if os(iOS)
    public var uiKeyboardType: UIKeyboardType {
        switch self {
        case .default: return .default
        case .emailAddress: return .emailAddress
        case .numberPad: return .numberPad
        case .phonePad: return .phonePad
        case .URL: return .URL
        case .decimalPad: return .decimalPad
        case .twitter: return .twitter
        case .webSearch: return .webSearch
        case .password: return .default // Use default keyboard but handle secureField separately
        }
    }
    #endif
}

public struct DomainKeyboardTypeModifier: ViewModifier {
    private let keyboardType: DomainKeyboardType
    
    public func body(content: Content) -> some View {
        #if os(iOS)
        return content
            .keyboardType(keyboardType.uiKeyboardType)
            .modifier(PasswordVisibilityModifier(keyboardType: keyboardType))
        #else
        return content
        #endif
    }
    
    public init(keyboardType: DomainKeyboardType) {
        self.keyboardType = keyboardType
    }
}

#if os(iOS)
private struct PasswordVisibilityModifier: ViewModifier {
    let keyboardType: DomainKeyboardType
    
    func body(content: Content) -> some View {
        if keyboardType == .password {
            return AnyView(content.textContentType(.password).textInputAutocapitalization(.never))
        } else {
            return AnyView(content)
        }
    }
}
#endif

public extension View {
    func domainKeyboardType(_ type: DomainKeyboardType) -> some View {
        modifier(DomainKeyboardTypeModifier(keyboardType: type))
    }
}
