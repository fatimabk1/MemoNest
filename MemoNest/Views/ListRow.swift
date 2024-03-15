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
    let onActionSelected: (RowAction) -> Void
    
    var body: some View {
        
        HStack {
            Image(systemName: icon)
            Text(name)
            Spacer()
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
        .background(.pink.opacity(0.3))
    }
}

#Preview {
    ListRow(name: "Folder",
            icon: "Folder"){_ in }
}
