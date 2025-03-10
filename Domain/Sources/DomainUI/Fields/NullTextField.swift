//
//  NullTextField.swift
//  Domain
//
//  Created by Kevin Kelly on 3/9/25.
//

import SwiftUI
import Domain

public struct NullTextField: View {
    
    @Binding private var string: String?
    @State private var displayString: String
       
    public var body: some View {
        TextField(label, text: $displayString, prompt: prompt)
            .keyboardType(.default)
            .onChange(of: displayString) { oldValue, newValue in
                string = newValue.nulled()
            }
    }
    
    public init(
        text: Binding<String?>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._string = text
        self.displayString = text.wrappedValue.null
        self.label = label
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
}
