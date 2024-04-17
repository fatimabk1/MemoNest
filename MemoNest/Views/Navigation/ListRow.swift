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
    @State var showPlaybackView = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if item is Folder {
                        onListRowTap(item)
                    } else {
                        showPlaybackView.toggle()
                    }
                } label: {
                    VStack {
                        ListRow(item: item)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Menu {
                    Button("Rename") { onActionSelected(.rename) }
                    Button("Delete") { onActionSelected(.delete) }
                    Button("Move") { onActionSelected(.move) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .padding()
                }
            }
            if showPlaybackView, let item = item as? AudioRecording {
                PlaybackView(recording: item)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct TappableListRow: View {
    let item: Item
    let onListRowTap: (Item) -> Void
    
    var body: some View {
        Button {
            if item is Folder {
                onListRowTap(item)
            }
        } label: {
            ListRow(item: item)
        }
        .background(Color("PopupBackground"))
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
                if item is AudioRecording {
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
        .background(Color("PopupBackground"))
    }
}


#Preview {
    @State var tapped = false
    return Group {
        List {
            TappableListRowWithMenu( item: Folder(name: "folder"), onListRowTap: {_ in }, onActionSelected: {_ in})
            TappableListRowWithMenu( item:  AudioRecording.sample, onListRowTap: {_ in }, onActionSelected: {_ in})
            TappableListRowWithMenu( item:  AudioRecording.sample, onListRowTap: {_ in }, onActionSelected: {_ in})
            TappableListRowWithMenu( item:  AudioRecording.sample, onListRowTap: {_ in }, onActionSelected: {_ in})
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }
}
