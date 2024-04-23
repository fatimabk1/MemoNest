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
    
    private let gradient = LinearGradient(colors: [Colors.listRowStart, Colors.listRowEnd], startPoint: .topLeading, endPoint: .bottomTrailing)

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
                    if item.isFolder() {
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
                        .foregroundStyle(Colors.lighter)
                }
            }
            if showPlaybackView, item.isRecording() {
                PlaybackView(recording: item)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
//                .stroke(Colors.main)
                .foregroundStyle(gradient)
//                .foregroundStyle(Colors.listRowStart)
//                .foregroundStyle(Colors.listRowEnd)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.black, radius: 5)
        )
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
        HStack(alignment: .top) {
            Image(systemName: item.getIcon())
            VStack(alignment: .leading) {
                HStack {
                    Text(item.name)
                        .lineLimit(0)
                        .foregroundStyle(Colors.mainText)
                    Spacer()
                    if item.isRecording() {
                        Text("\(formattedDuration)")
                            .foregroundStyle(Colors.secondaryText)
                            .font(.callout)
                    }
                }
                
                Text(formattedDate)
                    .font(.callout)
                    .foregroundStyle(Colors.secondaryText)
                    .padding(.trailing)
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
            TappableListRowWithMenu( item: Item(name: "folder", type: .folder), onListRowTap: {_ in }, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
            TappableListRowWithMenu( item: longNameAudio, onListRowTap: {_ in }, onActionSelected: {_ in})
                .listRowBackground(Color.clear)
            TappableListRow( item:  longNameAudio /*Item.sampleRecording*/, onListRowTap: {_ in })
                .listRowBackground(Color.clear)
            ListRow( item:  Item.sampleRecording)
                .listRowBackground(Color.clear)
        }
//        .listStyle(.inset)
        .background(Colors.main)
        .scrollContentBackground(.hidden)
        .listRowBackground(Colors.main)
        
    }
}
