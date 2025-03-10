//
//  FormEntry.swift
//  hede
//
//  Created by Kevin Kelly on 9/12/24.
//

import SwiftUI

public struct FormEntry<
    Content: View
    , Label: View
    , Help: View
>: View {
    private let showHelp: Bool
    private let content: () -> Content
    private let label: () -> Label
    private let help: () -> Help
    
    public var body: some View {
        Section {
            content()
        } header: {
            label()
        } footer: {
            if showHelp {
                help()
            }
        }
    }
    
    public init(
        showHelp: Bool = false
        , @ViewBuilder content: @escaping () -> Content
        , @ViewBuilder label: @escaping () -> Label = { EmptyView() }
        , @ViewBuilder help: @escaping () -> Help = { EmptyView() }
    ) {
        self.showHelp = showHelp
        self.content = content
        self.label = label
        self.help = help
    }
}

//#Preview {
//    FormEntry()
//}
