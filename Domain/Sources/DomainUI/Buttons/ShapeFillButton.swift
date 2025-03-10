//
//  CompletionShape.swift
//  hede
//
//  Created by Kevin Kelly on 3/6/25.
//

import SwiftUI

/// Button that fills a shape on each press, depending on the amount of steps.
public struct ShapeFillButton<Content: Shape>: View {
    @Binding private var count: Int
    private let steps: Int
    
    private var safeSteps: Int { max(steps, 0) }
    private var fillFraction: Double { Double(count) / Double(safeSteps) }

    public var body: some View {
        Button {
            count = min(steps, count + 1)
        } label: {
            ZStack {
                shape
                    .stroke(strokeColor, lineWidth: strokeWidth)
                shape
                    .trim(from: 0, to: min(max(fillFraction, 0), 1))
                    .rotation(Angle(degrees: 0) + startAngle)
                    .fill(fillColor)
            }
        }
    }
    
    public init(
        count: Binding<Int>
        , steps: Int = 2
        , shape: Content = Circle()
        , startAngle: Angle = Angle(degrees: 45)
        , strokeColor: Color = .gray
        , strokeWidth: CGFloat = 2
        , fillColor: Color = .primary
    ) {
        self._count = count
        self.steps = steps
        self.shape = shape
        self.startAngle = startAngle
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.fillColor = fillColor
    }
    
    private let shape: Content
    private let startAngle: Angle
    private let strokeColor: Color
    private let strokeWidth: CGFloat
    private let fillColor: Color
}

#Preview {
    VStack {
        ShapeFillButton(
            count: .constant(0)
            , steps: 2
            , shape: Circle()
            , startAngle: Angle(degrees: 45)
            , strokeColor: .gray
            , strokeWidth: 5
            , fillColor: .primary
        )
    }
    .padding(100)

    
}
