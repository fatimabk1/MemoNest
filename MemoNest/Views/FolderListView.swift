//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI
import Combine

enum ItemAction {
    case move, delete, rename, add, none
}

struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    @State var itemToDelete: Item?
    @State var showDeletionAlert = false
    
    init(database: DataManager) {
        self.viewModel = FolderListViewModel(database: database)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    titleView
                    
                    sortPicker
                        .buttonStyle(.borderedProminent)
                    
                    List {
                        ForEach(viewModel.items, id: \.id) { item in
                            createListRow(item: item)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets())
                        }
                    }
                    .listStyle(.inset)
                    .listItemTint(Colors.background)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: .infinity)
                    
                    bottomToolbar
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(Colors.background)
                .navigationDestination(isPresented: $viewModel.moveViewIsPresented) {
                    if let item = viewModel.editingItem, viewModel.itemAction == .move {
                        MoveItemView(moveItem: item, database: viewModel.database,
                                        isPresenting: $viewModel.moveViewIsPresented) { destinationFolderID in
                            viewModel.moveItem(item: item, destination: destinationFolderID)
                        }
                        .navigationBarBackButtonHidden()
                    }
                }
                .onAppear {
                    viewModel.handleOnAppear()
                }
                .alert(isPresented: $viewModel.hasError) {
                    Alert(title: Text("\(viewModel.error?.title ?? "")"))
                }
                .alert(isPresented: $showDeletionAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete this?"),
                        message: Text("Deletions cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            if let itemToDelete {
                                viewModel.handleMenuTap(item: itemToDelete, action: .delete)
                            } else {
                                viewModel.hasError = true
                                viewModel.error = DatabaseError.itemNotFound
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                addRenameInputView
            }
        }
    }
    
    private var titleView: some View {
        HStack(alignment: .center) {
            BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()}
            Text(viewModel.currentFolderTitle)
                .foregroundColor(Colors.mainText)
                .memoNestFont(style: .title)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.trailing)
        .padding(.leading, viewModel.hasParent ? 0 : 15)
        .padding(.top)
    }
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            if viewModel.isRecording {
                recordingView
                    .transition(.move(edge: .bottom))
            }
            HStack {
                homeButton
                    .disabled(viewModel.isLoading)
                Spacer()
                recordButton
                    .disabled(viewModel.isLoading)
                Spacer()
                addFolderButton
                    .disabled(viewModel.isLoading)
            }
            .padding()
            .background(Colors.background)
        }
    }
    
    private var recordingView: some View {
        VStack {
            VStack(alignment: .leading) {
                TextField("Recording Name", text: $viewModel.recordingName)
                    .memoNestFont(style: .body, fontWeight: .semibold)
                    .foregroundStyle(Colors.mainText)
                VStack {
                    HStack {
                        Text(viewModel.recordingParentTitle)
                            .foregroundStyle(Colors.blueLight)
                            .memoNestFont(style: .callout)
                        Spacer()
                        Button {
                            viewModel.updateParentFolder(parentID: viewModel.currentFolder?.id, folderTitle: viewModel.currentFolderTitle)
                        } label: {
                            Text("Set Location")
                                .foregroundStyle(Colors.blueMedium)
                                .memoNestFont(style: .callout)
                        }
                    }
                    Text("\(viewModel.formattedcurrentDuration)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Colors.blueLight)
                        .memoNestFont(style: .callout)
                }
            }
            .padding()
        }
        .background(Colors.background)
    }
    
    private var sortPicker: some View {
        Menu {
            Picker(selection: $viewModel.sortType) {
                ForEach(SortType.allCases, id: \.self) {
                    Text($0.rawValue)
                        .memoNestFont(style: .body)
                        .foregroundStyle(Colors.blueVeryLight)
                }
            } label: {}
        } label: {
            Text(viewModel.sortType.rawValue)
                .memoNestFont(style: .body)
                .foregroundStyle(Colors.blueVeryLight)
        }
        .buttonStyle(.plain)
        .tint(Colors.blueVeryDark)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var addRenameInputView: some View {
        if viewModel.itemAction == .rename || viewModel.itemAction == .add {
            InputPopup(popup: viewModel.popup) { newName in
                if let newName {
                    if let item = viewModel.editingItem, viewModel.itemAction == .rename {
                        print("In item popup rename item")
                        viewModel.renameItem(item: item, name: newName)
                    }
                    
                    if viewModel.itemAction == .add {
                        viewModel.addFolder(folderName: newName)
                    }
                }
                viewModel.setAction(action: .none, item: nil)
            }
        }
    }
    
    private var homeButton: some View {
        Button {
            viewModel.loadItems(atFolderID: nil)
        } label: {
            Image(systemName: "house")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Colors.blueLight)
        }
    }
    
    private var recordButton: some View {
        Button {
            withAnimation {
                viewModel.handleRecordButtonPress()
            }
        } label: {
            Image(systemName: "waveform.circle")
                .resizable()
                .foregroundStyle(viewModel.isRecording ? Colors.icon : Colors.blueLight)
                .frame(width: 50, height: 50)
        }
        .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5), isActive: viewModel.isRecording)
    }
    
    private var addFolderButton: some View {
        Button {
            viewModel.setAction(action: .add, item: nil)
        } label: {
            Image(systemName: "folder.fill.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundStyle(Colors.blueLight)
        }
        .opacity(viewModel.itemAction == .move ? 0 : 1)
    }
    
    @ViewBuilder
    private func createListRow(item: Item) -> some View {
        if item.isFolder() {
            FolderRow(item: item, onListRowTap: viewModel.changeFolder,
                      onActionSelected: { action in
                if action == .delete {
                    itemToDelete = item
                    showDeletionAlert = true
                    return
                }
                viewModel.handleMenuTap(item: item, action: action)
            })
        } else {
            RecordingRow(item: item,
                         showPlaybackView: item.id == viewModel.playbackItemID,
                         onListRowTap: { item in
                viewModel.setRecording(item: item)
            },
                         playbackView: { AnyView(PlaybackView) },
                         onActionSelected: { action in
                if action == .delete {
                    itemToDelete = item
                    showDeletionAlert = true
                    return
                }
                viewModel.handleMenuTap(item: item, action: action)
            })
        }
    }
    
    @ViewBuilder
    var PlaybackView: some View {
        VStack(spacing: 0) {
            playbackCurrentDuration
            if viewModel.playbackDuration > 0 {
                playbackSlider
            }
            controlButtons
        }
        .padding()
        .background(Colors.background)
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("\(viewModel.error?.title ?? "")"))
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 50) {
            Spacer()
            seekBackwardButton
            playPauseButton
            seekForwardButton
            Spacer()
        }
        .padding(.top)
    }
    
    private var playbackCurrentDuration: some View {
        Text("\(FormatterService.formatTimeInterval(seconds: viewModel.currentPlaybackTime))")
            .frame(maxWidth: 100)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(Colors.blueLight)
            .memoNestFont(style: .caption)
    }
    
    private var playbackSlider: some View {
        Slider(value: $viewModel.currentPlaybackTime,
               in: 0...viewModel.playbackDuration,
               step: 0.1,
               onEditingChanged: { editing in
            if !editing {
                viewModel.seek(to: viewModel.currentPlaybackTime)
            }
        })
        .tint(Colors.icon)
        .onAppear {
            UISlider.appearance().maximumTrackTintColor = UIColor(Colors.blueMedium)
            UISlider.appearance().thumbTintColor = UIColor(Colors.icon)
        }
    }
    
    private var playPauseButton: some View {
        Button {
            if viewModel.isPlaying {
                viewModel.pauseRecording()
            } else {
                viewModel.playRecording()
            }
        } label: {
            Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Colors.blueMedium)
    }
    
    private var seekForwardButton: some View {
        Button {
            if viewModel.isPlaying {
                viewModel.seekForward()
            }
        } label: {
            Image(systemName: "goforward.15")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Colors.blueMedium)
    }
    
    private var seekBackwardButton: some View {
        Button {
            if viewModel.isPlaying {
                viewModel.seekBackward()
            }
        } label: {
            Image(systemName: "gobackward.15")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Colors.blueMedium)
    }
}

#Preview {
    let audioInfo = AudioMetaData(duration: 123, recordingURLFileName: "www.sample.com")
    let audio1 = Item(name: "Philosophy Lecture #4, The Self", date: Date(), type: .recording, audioInfo: audioInfo)
    let audio2 = Item(name: "PHilosophy Review nOtes", date: Date(), type: .recording, audioInfo: audioInfo)
    return NavigationStack {
        FolderListView(database: MockDataManager(folders: MockDataManager.sampleFolders, files: [audio1, audio2]))
    }
}
