//
//  ListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI


struct RowMenu: View {
    let onActionSelected: (ItemAction) -> Void
    
    var body: some View {
        Menu {
            Button {
                onActionSelected(.rename)
            } label: {
                Text("Rename")
                    .customFont(style: .body)
            }
            Button {
                onActionSelected(.delete)
            } label: {
                Text("Delete")
                    .customFont(style: .body)
            }
            Button {
                onActionSelected(.move)
            } label: {
                Text("Move")
                    .customFont(style: .body)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .padding(.horizontal)
                .foregroundStyle(Colors.blueMedium)
                .frame( maxHeight: .infinity)
        }
        
    }
}

struct FolderRow: View {
    let item: Item
    let onListRowTap: (Item) -> Void
    let onActionSelected: (ItemAction) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    onListRowTap(item)
                } label: {
                    ListRow(item: item)
                }
                RowMenu(onActionSelected: onActionSelected)
            }
        }
    }
}

struct RecordingRow: View {
    let item: Item
    let showPlaybackView: Bool
    let onListRowTap: (Item) -> Void
    let onActionSelected: (ItemAction) -> Void
    let playbackView: () -> AnyView
    
    init(item: Item, showPlaybackView: Bool, onListRowTap: @escaping (Item) -> Void, playbackView: @escaping () -> AnyView, onActionSelected: @escaping (ItemAction) -> Void) {
        self.item = item
        self.showPlaybackView = showPlaybackView
        self.onListRowTap = onListRowTap
        self.playbackView = playbackView
        self.onActionSelected = onActionSelected
    }
    
    private var formattedDuration: String {
        if let duration = item.audioInfo?.duration {
            FormatterService.formatTimeInterval(seconds: duration)
        } else {
            ""
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    onListRowTap(item)
                } label: {
                    ListRow(item: item)
                }
                RowMenu(onActionSelected: onActionSelected)
            }
            if showPlaybackView, item.isAudio() {
                playbackView()
            }
        }
    }
}

struct TappableListRow: View {
    let item: Item
    let onListRowTap: (Item) -> Void
    
    var body: some View {
        Button {
            if item.isFolder(){
                onListRowTap(item)
            }
        } label: {
            ListRow(item: item)
        }
    }
}

struct ListRow: View {
    let item: Item
    
    private var formattedDate: String {
        FormatterService.formatDate(date: item.date)
    }
    
    private var formattedDuration: String {
        if let duration = item.audioInfo?.duration {
            FormatterService.formatTimeInterval(seconds: duration)
        } else {
            ""
        }
    }
        
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: item.getIcon())
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Colors.icon)
                .padding(.trailing, 5)
            VStack(alignment: .leading) {
                HStack {
                    Text(item.name)
                        .lineLimit(2)
                        .foregroundStyle(Colors.mainText)
                        .customFont(style: .body, fontWeight: item.isFolder() ? .semibold : .regular)
                    Spacer()
                    if item.isAudio() {
                        Text("\(formattedDuration)")
                            .foregroundStyle(Colors.blueLight)
                            .customFont(style: .footnote, fontWeight: .light)
                    }
                }
                
                if item.isAudio() {
                    Text(formattedDate)
                        .foregroundStyle(Colors.blueVeryLight)
                        .customFont(style: .footnote, fontWeight: .light)
                        .padding(.trailing)
                }
            }
        }
        .padding(.vertical)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    @State var tapped = false
    
    let longNameAudio = Item(id: UUID(), name: "really really long recording nam,e lets see okay", parent: nil, date: Date(), type: .recording, audioInfo: Item.sampleAudioInfo)
    
    return Group {
        List {
            FolderRow( item: Item(name: "folder", type: .folder), onListRowTap: {_ in }, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            RecordingRow( item: longNameAudio, showPlaybackView: true, onListRowTap: {_ in }, playbackView: {AnyView(Text("playback view"))}, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            RecordingRow( item: longNameAudio, showPlaybackView: true, onListRowTap: {_ in }, playbackView: {AnyView(RoundedRectangle(cornerRadius: 15).foregroundStyle(.red))}, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
        }
        .listStyle(.inset)
        .background(Colors.background)
        .scrollContentBackground(.hidden)
        .listRowBackground(Colors.background)
        
    }
}
