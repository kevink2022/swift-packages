//
//  NullNumberField.swift
//  hede
//
//  Created by Kevin Kelly on 3/7/25.
//

import SwiftUI


public struct NullNumberField: View {
    
    @Binding private var integer: Int?
    @Binding private var double: Double?
    @State private var string: String
    @FocusState private var focused: Bool
       
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .domainKeyboardType(number.keyboardType)
            .onChange(of: string) { _, newValue in
                switch number {
                case .integer: integer = Int(newValue)
                case .double: double = Double(newValue)
                }
            }
        
            .onChange(of: integer) { _, newValue in
                guard let newValue = newValue else { return }
                string = String(newValue)
            }
            .onChange(of: double) { _, newValue in
                guard let newValue = newValue else { return }
                string = String(newValue)
            }
    }
    
    public init(
        integer: Binding<Int?>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = integer
        self._double = .constant(0)
        
        self.number = .integer
        self.string = integer
            .wrappedValue
            .nilOr { String($0) } ?? ""

        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    public init(
        double: Binding<Double?>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = .constant(0)
        self._double = double
        
        self.number = .double
        self.string = double
            .wrappedValue
            .nilOr { String($0) } ?? ""
        
        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
    private var number: Self.Number
    
    private enum Number {
        case integer, double
        
        var keyboardType: DomainKeyboardType {
            switch self {
            case .integer: .numberPad
            case .double: .decimalPad
            }
        }
    }
}

#Preview {
    NullNumberField(double: .constant(nil), prompt: "0")
    NullNumberField(integer: .constant(0))
    IntegerField(integer: .constant(0))
    DoubleField(double: .constant(0))
}

public struct NullIntegerField: View {
    
    @Binding private var integer: Int?
    @State private var string: String
       
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .domainKeyboardType(.numberPad)
            .onChange(of: string) { oldValue, newValue in
                integer = Int(newValue)
            }
    }
    public init(
        integer: Binding<Int?>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = integer
        
        self.label = label
        self.string = integer
            .wrappedValue
            .nilOr { String($0) } ?? ""
       
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
}

public struct NullDoubleField: View {
    
    @Binding private var double: Double?
    @State private var string: String
    
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .domainKeyboardType(.decimalPad)
            .onChange(of: string) { oldValue, newValue in
                double = Double(newValue)
            }
    }
    
    public init(
        double: Binding<Double?>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._double = double
        
        self.label = label
        self.string = double
            .wrappedValue
            .nilOr { String($0) } ?? ""
        
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
}
