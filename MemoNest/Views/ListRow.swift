//
//  ListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

enum RowAction {
    case delete, rename
}

struct ListRow: View {
    let name: String
    let icon: String
    let itemID: UUID
    let onListRowTap: (UUID) -> Void
    let onActionSelected: (RowAction) -> Void
    
    var body: some View {
        
        HStack {
            Button {
                onListRowTap(itemID)
            } label: {
                HStack {
                    Image(systemName: icon)
                    Text(name)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Menu {
                Button("Rename") { onActionSelected(.rename) }
                Button {
                    onActionSelected(.delete)
                } label: {
                    Text("Delete")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .padding()
    }
}

#Preview {
    ListRow(name: "Folder", icon: "Folder", itemID: UUID(), onListRowTap: {_ in }, onActionSelected: { _ in  })
}
