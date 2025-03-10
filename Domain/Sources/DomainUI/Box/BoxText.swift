//
//  BoxText.swift
//  hede
//
//  Created by Kevin Kelly on 9/10/24.
//

import SwiftUI

public struct BoxText: View {
    private let text: any StringProtocol
    
    public  var body: some View {
        Text(text)
            .font(V.F.boxLarge)
            .lineLimit(2)
    }

    public  init(
        _ text: any StringProtocol
    ) {
        self.text = text
    }
}

#Preview {
    BoxText("Test")
}

public struct BoxImage: View {
    
    private let image: String
    private let initializer: BoxImage.Initializer
    
    public var body: some View {
        switch initializer {
        case .blank: Image(image) .font(V.F.boxLarge)
        case .systemName: Image(systemName: image) .font(V.F.boxLarge)
        }
    }
    
    public init(_ image: any StringProtocol) {
        self.image = String(image)
        self.initializer = .blank
    }
    
    public init(systemName image: any StringProtocol) {
        self.image = String(image)
        self.initializer = .systemName
    }
    
    enum Initializer: CaseIterable {
        case blank, systemName
    }
}

#Preview {
    BoxText("Test")
}
