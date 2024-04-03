//
//  ListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI


struct TappableListRowWithMenu: View {
    let item: Item
    let onListRowTap: (Item) -> Void
    let onActionSelected: (ItemAction) -> Void
    
    var body: some View {
        HStack {
            TappableListRow(item: item,
                            onListRowTap: onListRowTap)
                .frame(maxWidth: .infinity, alignment: .trailing)
    
            Menu {
                Button("Rename") { onActionSelected(.rename) }
                Button("Delete") { onActionSelected(.delete) }
                Button("Move") { onActionSelected(.move) }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            
        }
    }
}

struct TappableListRow: View {
    let item: Item
    let onListRowTap: (Item) -> Void
    
    var body: some View {
        Button {
            onListRowTap(item)
        } label: {
            ListRow(item: item)
        }
    }
}

struct ListRow: View {
    let item: Item
    
    var formattedDate: String {
        let dateFormatter = Date.FormatStyle().day().month().year()
        return item.date.formatted(dateFormatter)
    }
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
            Text(item.name)
            Spacer()
            Text(formattedDate)
                .font(.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    return Group {
        ListRow(item: Folder(name: "folderA"))
        TappableListRow( item:  Folder(name: "folderA"), onListRowTap: {_ in })
        TappableListRowWithMenu( item: Folder(name: "folderA"), onListRowTap: {_ in }, onActionSelected: { _ in  })
    }
}
