//
//  ListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

enum RowAction {
    case delete, rename, move
}


struct TappableListRowWithMenu: View {
    let name: String
    let icon: String
    let item: Item
    let onListRowTap: (Item) -> Void
    let onActionSelected: (RowAction) -> Void
    
    var body: some View {
        ZStack {
            TappableListRow(name: name, icon: icon, item: item,
                            onListRowTap: onListRowTap)
    
            Menu {
                Button("Rename") { onActionSelected(.rename) }
                Button("Delete") { onActionSelected(.delete) }
                Button("Move") { onActionSelected(.move) }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct TappableListRow: View {
    let name: String
    let icon: String
    let item: Item
    let onListRowTap: (Item) -> Void
    
    var body: some View {
        Button {
            onListRowTap(item)
        } label: {
            ListRow(name: name, icon: icon, item: item)
        }
    }
}

struct ListRow: View {
    let name: String
    let icon: String
    let item: Item
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(name)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//struct ListRow: View {
//    let name: String
//    let icon: String
//    let item: Item
//    let onListRowTap: (Item) -> Void
//    let onActionSelected: (RowAction) -> Void
//    
//    var body: some View {
//        
//        HStack {
//            Button {
//                onListRowTap(item)
//            } label: {
//                HStack {
//                    Image(systemName: icon)
//                    Text(name)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            
//            Menu {
//                Button("Rename") { onActionSelected(.rename) }
//                Button("Delete") { onActionSelected(.delete) }
//                Button("Move") { onActionSelected(.move) }
//            } label: {
//                Image(systemName: "ellipsis.circle")
//            }
//        }
//        .padding()
//    }
//}

#Preview {
    return Group {
        ListRow(name: "Folder", icon: "Folder", item: Folder(name: "folderA"))
        TappableListRow(name: "Folder", icon: "Folder", item:  Folder(name: "folderA"), onListRowTap: {_ in })
        TappableListRowWithMenu(name: "Folder", icon: "Folder", item: Folder(name: "folderA"), onListRowTap: {_ in }, onActionSelected: { _ in  })
    }
}
