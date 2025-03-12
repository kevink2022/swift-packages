//
//  WeekdayWeekPicker.swift
//  Domain
//
//  Created by Kevin Kelly on 3/11/25.
//

import SwiftUI
import Domain

public struct WeekdayWeekPicker: View {
    @Binding private var weekdays: [Weekday]
    private let variant: Self.Variant
    
    public var body: some View {
        HStack {
            ForEach(Weekday.allCases, id: \.self) { weekday in
                Button {
                    withAnimation { isSelected(weekday) ? remove(weekday) : add(weekday) }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isSelected(weekday) ? Color.accentColor : Color.clear)
                            .opacity(0.4)
                    
                        Text(weekday.veryShortName)
                    }
                }
                .disabled(buttonDisabled)
                .foregroundStyle(.primary)

            }
        }
    }
    
    private var buttonDisabled: Bool { variant == .view }
    private let font: Font
    
    private func isSelected(_ weekday: Weekday) -> Bool {
        weekdays.contains(where: { $0 == weekday })
    }
    
    private func add(_ weekday: Weekday) {
        weekdays.append(weekday)
    }
    
    private func remove(_ weekday: Weekday) {
        weekdays.removeAll { $0 == weekday }
    }
    
    private enum Variant { case edit, view }
    
    public init(
        _ weekdays: Binding<[Weekday]>
        , font: Font = .body
    ) {
        self._weekdays = weekdays
        self.variant = .edit
        self.font = font
    }
    
    public init(
        _ weekdays: [Weekday]
        , font: Font = .body
    ) {
        self._weekdays = .constant(weekdays)
        self.variant = .view
        self.font = font
    }
}

#Preview {
    TestView()
    WeekdayWeekPicker([.sunday])
}

fileprivate struct TestView: View {
    @State var weekdays = [Weekday]()

    var body: some View {
        WeekdayWeekPicker($weekdays)
    }
}
