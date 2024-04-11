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
        FormatterService.formatDate(date: item.date)
    }
    
    var formattedDuration: String {
        if let duration = item.audioInfo?.duration {
            FormatterService.formatTimeInterval(seconds: duration)
        } else {
            ""
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: item.icon)
            VStack(alignment: .leading) {
                Text(item.name)
                    .lineLimit(0)
                if let duration = item.audioInfo?.duration {
                    Text("\(formattedDuration)")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            Spacer()
            Text(formattedDate)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    return Group {
        ListRow(item: Folder(name: "A really really really long row item name, lets see if it spills over and wraps!"))
        TappableListRow( item:  Folder(name: "folderA"), onListRowTap: {_ in })
        TappableListRowWithMenu( item: Folder(name: "folderA"), onListRowTap: {_ in }, onActionSelected: { _ in  })
        ListRow(item: AudioRecording.sample)
        TappableListRow( item:  AudioRecording.sample, onListRowTap: {_ in })
        TappableListRowWithMenu( item: AudioRecording.sample, onListRowTap: {_ in }, onActionSelected: { _ in  })
    }
}
