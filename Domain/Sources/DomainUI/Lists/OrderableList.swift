//
//  OrderableList.swift
//  Domain
//
//  Created by Kevin Kelly on 3/9/25.
//

import SwiftUI

public struct OrderableList: View {
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    public var body: some View {
        List {
            Section(header: Text("Draggable Section")) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .onDrag {
                            // Create a draggable item identifier
                            return NSItemProvider(object: item as NSString)
                        }
                }
                .onMove { indices, newOffset in
                    items.move(fromOffsets: indices, toOffset: newOffset)
                }
            }
            
            Section(header: Text("Regular Section")) {
                Text("Non-draggable item 1")
                Text("Non-draggable item 2")
            }
        }
        /*
        .toolbar {
            EditButton()
        }
        */
    }
    
    public init() {}
}
#Preview {
    OrderableList()
}
