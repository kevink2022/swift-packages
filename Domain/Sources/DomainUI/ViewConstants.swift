//
//  ViewConstants.swift
//  Domain
//
//  Created by Kevin Kelly on 3/8/25.
//

import SwiftUI
import Domain

internal typealias V = ViewConstants

/// The default constant values for DomanUI views.
public struct ViewConstants {
    
    internal typealias F = ViewConstants.Fonts
    public struct Fonts {
        private static let standard = Font.Design.default
        
        public static let largeButtonText = Font.system(
            .title3
            , design: standard
            , weight: .semibold
        )
        
        public static let boxSmall = Font.system(
            .title3
            , design: standard
            , weight: .regular
        )
        
        public static let boxLarge = Font.system(
            .title2
            , design: standard
            , weight: .heavy
        )
        
        public static let semiLargeSymbol = Font.system(
            .title
            , design: standard
            , weight: .bold
        )
        
        public static let emptyScreenInformational = Font.system(
            .title2
            , design: standard
            , weight: .semibold
        )
    }
    
    public static let buttonCornerRadius: CGFloat = 12
    
    public static let boxCorner: CGFloat = 10
    public static let boxOpacity: CGFloat = 0.6
    public static let boxTextOpacity: CGFloat = 0.6
    public static let boxExternalPadding: CGFloat = 6
    public static let boxInternalPadding: CGFloat = 8
     
    public static let noContentMessageOpacity: CGFloat = 0.4
    public static let noContentBottomPadding: CGFloat = 54
}
