//
//  NoContentMessage.swift
//  hede
//
//  Created by Kevin Kelly on 9/11/24.
//

import SwiftUI

public struct NoContentMessage<Content: View>: View {
   
    private let message: String
    private let action: () -> ()
    private let label: () -> Content

    public var body: some View {
        
        Spacer()
        
        Text(message)
            .font(V.F.emptyScreenInformational)
            .opacity(V.noContentMessageOpacity)
        
        Button {
            action()
        } label: {
            label()
                .font(V.F.semiLargeSymbol)
        }
        .padding(.bottom, V.noContentBottomPadding)
    }
    
    public init(
        message: String
        , action: @escaping () -> () = { }
        , @ViewBuilder label: @escaping () -> Content = { EmptyView() }
    ) {
        self.message = message
        self.action = action
        self.label = label
    }
    
}

#Preview {
    NoContentMessage(message: "No Recurring Task Sources.") {
        print("test")
        //navigator.presentSheet(RecurringSourceFormView())
    } label: {
        Label("Add Source", systemImage: "plus")
    }
    
    
}
