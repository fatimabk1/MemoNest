//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

enum ItemAction {
    case move, delete, rename, add, none
}

// TO DO LIST:
/*
 [RTIInputSystemClient remoteTextInputSessionWithID:performInputOperation:]  perform input operation requires a valid sessionID. inputModality = Keyboard, inputOperation = <null selector>, customInfoType = UIEmojiSearchOperations
 */


struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    @ObservedObject var recordingViewModel: RecordingViewModel
    
    init(database: DataManager) {
        self.viewModel = FolderListViewModel(database: database)
        self.recordingViewModel = RecordingViewModel(database: database)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    sortPicker
                        .buttonStyle(.borderedProminent)
                        .padding(.bottom)
                    List {
                        ForEach(viewModel.items, id: \.id) { item in
                            createListRow(item: item)
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.inset)
                    .listItemTint(Colors.main)
                    .scrollContentBackground(.hidden)
                    .frame(maxHeight: .infinity)
                    bottomToolbar
                }
                .background(Colors.main)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(viewModel.currentFolderTitle)
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
                .alert(isPresented: $recordingViewModel.hasError) {
                    Alert(title: Text("\(recordingViewModel.error?.title ?? "")"))
                }
                .alert(isPresented: $viewModel.hasError) {
                    Alert(title: Text("\(viewModel.error?.title ?? "")"))
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()}
                    }
                }
                addRenameInputView
            }
        }
    }
    
    private var bottomToolbar: some View {
        VStack(spacing: 0) {
            if recordingViewModel.isRecording {
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
            .background(Colors.main)
        }
    }
    
    private var recordingView: some View {
        VStack {
            VStack(alignment: .leading) {
                TextField("Recording Name", text: $recordingViewModel.recordingName)
                    .fontWeight(.semibold)
                    .foregroundStyle(Colors.mainText)
                VStack {
                    HStack {
                        Text(recordingViewModel.recordingParentTitle)
                            .foregroundStyle(Colors.secondaryText)
                        Spacer()
                        Button {
                            recordingViewModel.updateParentFolder(parentID: viewModel.currentFolder?.id, folderTitle: viewModel.currentFolderTitle)
                        } label: {
                            Text("Set Location")
                                .foregroundStyle(Colors.accent)
                        }
                    }
                    Text("\(recordingViewModel.formattedcurrentDuration)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Colors.secondaryText)
                }
            }
            .padding()
        }
        .background(Colors.main)
    }
    
    private var sortPicker: some View {
        Picker("Sort", selection: $viewModel.sortType) {
            ForEach(SortType.allCases, id: \.self) {
                Text($0.toString())
            }
        }
        .pickerStyle(.menu)
        .tint(Colors.lighter)
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
                .foregroundStyle(Colors.lighter)
        }
    }
    
    private var recordButton: some View {
        Button {
            withAnimation {
                recordingViewModel.isRecording.toggle()
                // TODO: REMOVE - TESTING ONLY
//                if recordingViewModel.isRecording {
//                    recordingViewModel.stopRecording()
//                    recordingViewModel.addFile {
//                        viewModel.loadItems(atFolderID: viewModel.currentFolder?.id)
//                    }
//                } else {
//                    recordingViewModel.startRecording(parentID: viewModel.currentFolder?.id, folderTitle: viewModel.currentFolderTitle)
//                }
            }
        } label: {
            Image(systemName: "waveform.circle")
                .resizable()
                .foregroundStyle(recordingViewModel.isRecording ? Colors.secondary : Colors.lighter)
                .frame(width: 50, height: 50)
        }
        .symbolEffect(.variableColor.iterative, options: .repeating.speed(0.5), isActive: recordingViewModel.isRecording)
    }
    
    private var addFolderButton: some View {
        Button {
            viewModel.setAction(action: .add, item: nil)
        } label: {
            Image(systemName: "folder.fill.badge.plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundStyle(Colors.lighter)
        }
        .opacity(viewModel.itemAction == .move ? 0 : 1)
    }
    
    private func createListRow(item: Item) -> some View {
        TappableListRowWithMenu(item: item, onListRowTap: viewModel.setFolder) { action in
            if action == .delete {
                viewModel.removeItem(item: item)
            } else if action == .rename {
                viewModel.setAction(action: action, item: item)
            } else if action == .move {
                viewModel.setAction(action: action, item: item)
                viewModel.moveViewIsPresented = true
            }
        }
    }
}

#Preview {
    let audioInfo = AudioMetaData(duration: 123, recordingURLFileName: "www.sample.com")
    let audio1 = Item(name: "A really long name for a recording, let see how far it spills over!", date: Date(), type: .recording, audioInfo: audioInfo)
    let audio2 = Item(name: "Recording #4", date: Date(), type: .recording, audioInfo: audioInfo)
    return FolderListView(database: MockDataManager(folders: MockDataManager.sampleFolders, files: [audio1, audio2]))
}
