//
//  NumberArrayField.swift
//  Domain
//
//  Created by Kevin Kelly on 3/9/25.
//

import SwiftUI

public struct NumberArrayField: View {
    @Binding private var integers: [Int]
    @Binding private var doubles: [Double]
    private let variant: Self.Variant
    
    public var body: some View {
        switch variant {
        case .integers: IntegerArrayField(integers: $integers)
        case .doubles: DoubleArrayField(doubles: $doubles)
        }
    }
    
    public init(integers: Binding<[Int]>) {
        self._integers = integers
        self._doubles = .constant([])
        self.variant = .integers
    }
    
    public init(doubles: Binding<[Double]>) {
        self._integers = .constant([])
        self._doubles = doubles
        self.variant = .doubles
    }
    
    private enum Variant { case integers, doubles }
}

#Preview {
    NumberArrayField(integers: .constant([1, 3]))
    IntegerArrayField(integers: .constant([1, 3]))
    DoubleArrayField(doubles: .constant([1, 3]))
}

public struct IntegerArrayField: View {
    @FocusState private var focused: Bool
    @Binding private var integers: [Int]
    @State private var displayIntegers: [Int?]
    
    public var body: some View {
        VStack {
            ForEach(displayIntegers.indices, id: \.self) { index in
                NullNumberField(integer: $displayIntegers[index])
            }
            
            Button {
                displayIntegers.append(nil)
            } label: {
                Text("Add Number")
            }
            
            if !focused && displayIntegers.count != displayIntegers.compactMap({$0}).count {
                Button {
                    displayIntegers = displayIntegers.compactMap({$0})
                } label: {
                    Text("Flatten")
                }
            }
        }
        
        .onChange(of: displayIntegers) { oldValue, newValue in
            integers = newValue.compactMap({$0})
        }
    }
    
    public init(integers: Binding<[Int]>) {
        self._integers = integers
        self.displayIntegers = integers.wrappedValue
    }
}

public struct DoubleArrayField: View {
    @FocusState private var focused: Bool
    @Binding private var doubles: [Double]
    @State private var displayDoubles: [Double?]
    
    public var body: some View {
        VStack {
            ForEach(displayDoubles.indices, id: \.self) { index in
                NullNumberField(double: $displayDoubles[index])
            }
            
            Button {
                displayDoubles.append(nil)
            } label: {
                Text("Add Number")
            }
            
            if !focused && displayDoubles.count != displayDoubles.compactMap({$0}).count {
                Button {
                    displayDoubles = displayDoubles.compactMap({$0})
                } label: {
                    Text("Flatten")
                }
            }
        }
        
        .onChange(of: displayDoubles) { oldValue, newValue in
            doubles = newValue.compactMap({$0})
        }
    }
    
    public init(doubles: Binding<[Double]>) {
        self._doubles = doubles
        self.displayDoubles = doubles.wrappedValue
    }
}
