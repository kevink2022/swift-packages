//
//  NumberField.swift
//  hede
//
//  Created by Kevin Kelly on 3/7/25.
//

import SwiftUI

public struct NumberField: View {
    
    @Binding private var integer: Int
    @Binding private var double: Double
    @State private var string: String
       
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .keyboardType(number.keyboardType)
            .onChange(of: string) { oldValue, newValue in
                switch number {
                case .integer: integer = Int(newValue) ?? integer
                case .double: double = Double(newValue) ?? double
                }
            }
    }
    
    public init(
        integer: Binding<Int>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = integer
        self._double = .constant(0)
        
        self.number = .integer
        self.string = String(integer.wrappedValue)

        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    public init(
        double: Binding<Double>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = .constant(0)
        self._double = double
        
        self.number = .double
        self.string = String(double.wrappedValue)
        
        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
    private var number: Self.Number
    
    private enum Number {
        case integer, double
        
        var keyboardType: UIKeyboardType {
            switch self {
            case .integer: .numberPad
            case .double: .decimalPad
            }
        }
    }
}

#Preview {
    NumberField(double: .constant(0))
    NumberField(integer: .constant(0))
}

public struct IntegerField: View {
    
    @Binding private var integer: Int
    @State private var string: String
       
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .keyboardType(.numberPad)
            .onChange(of: string) { oldValue, newValue in
                integer = Int(newValue) ?? integer
            }
    }
    public init(
        integer: Binding<Int>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._integer = integer
        self.string = String(integer.wrappedValue ?? 0)
        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
}

public struct DoubleField: View {
    
    @Binding private var double: Double
    @State private var string: String
    
    public var body: some View {
        TextField(label, text: $string, prompt: prompt)
            .keyboardType(.decimalPad)
            .onChange(of: string) { oldValue, newValue in
                double = Double(newValue) ?? double
            }
    }
    
    public init(
        double: Binding<Double>
        , label: String = ""
        , prompt: String? = nil
    ) {
        self._double = double
        self.string = String(double.wrappedValue)
        self.label = label
        
        if let prompt = prompt { self.prompt = Text(prompt) }
        else { self.prompt = nil}
    }
    
    private var label: String
    private var prompt: Text?
}
