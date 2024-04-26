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
                .foregroundStyle(Colors.blueMedium)
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
    let onActionSelected: (ItemAction) -> Void
    
    @State var showPlaybackView = false
    @ObservedObject var playbackViewModel: PlaybackViewModel
    
    init(item: Item, onActionSelected: @escaping (ItemAction) -> Void) {
        self.item = item
        self.onActionSelected = onActionSelected
        playbackViewModel = PlaybackViewModel(item: item)
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
                    showPlaybackView.toggle()
                } label: {
                    ListRow(item: item)
                }
                RowMenu(onActionSelected: onActionSelected)
            }
            if showPlaybackView, item.isAudio() {
                PlaybackView(viewModel: playbackViewModel)
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
        .padding()
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
            RecordingRow( item: longNameAudio, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
        }
        .listStyle(.inset)
        .background(Colors.background)
        .scrollContentBackground(.hidden)
        .listRowBackground(Colors.background)
        
    }
}

//struct TappableListRowWithMenu: View {
//    let item: Item
//    let onListRowTap: (Item) -> Void
//    let onActionSelected: (ItemAction) -> Void
////    @ObservedObject var playbackViewModel: PlaybackViewModel?
//    @State var showPlaybackView = false
//    
//    init(item: Item, onListRowTap: @escaping (Item) -> Void, onActionSelected: @escaping (ItemAction) -> Void) {
//        self.item = item
//        self.onListRowTap = onListRowTap
//        self.onActionSelected = onActionSelected
////        if item.isRecording() {
////            playbackViewModel = PlaybackViewModel(item: item)
////        } else {
////            playbackViewModel = nil
////        }
//    }
//
//    private var formattedDuration: String {
//        if let duration = item.audioInfo?.duration {
//            FormatterService.formatTimeInterval(seconds: duration)
//        } else {
//            ""
//        }
//    }
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Button {
//                    if item.isFolder() {
//                        onListRowTap(item)
//                    } else {
//                        showPlaybackView.toggle()
//                    }
//                } label: {
//                    VStack {
//                        ListRow(item: item)
//                    }
//                }
////                RowMenu
//            }
////            if showPlaybackView, item.isRecording(), let playbackViewModel {
////                PlaybackView(viewModel: playbackViewModel)
////            }
//        }
//    }
//}
