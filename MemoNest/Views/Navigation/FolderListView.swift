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
 - slow launch w/ audio session & recording set up
 - Error with rename text input:
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
                NavigationStack {
                    VStack {
                        sortPicker
                            .buttonStyle(.borderedProminent)
                        folderList
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(viewModel.currentFolderTitle)
                }
                .navigationDestination(isPresented: $viewModel.moveViewIsPresented) {
                    if let item = viewModel.editingItem, viewModel.itemAction == .move {
                        MoveItemView(moveItem: item,
                                     database: viewModel.database,
                                     isPresenting: $viewModel.moveViewIsPresented) { destinationFolderID in
                            viewModel.moveItem(item: item, destination: destinationFolderID)
                        }
                                     .navigationBarBackButtonHidden()
                    }
                }
                .onAppear {
                    viewModel.handleOnAppear()
                    recordingViewModel.handleOnAppear()
                }
                .alert(isPresented: $recordingViewModel.hasError) {
                    Alert(title: Text("\(recordingViewModel.error?.title ?? "")"))
                }
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()}
                    }
                }
                bottomToolbar
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
                Spacer()
                recordButton
                Spacer()
                addFolderButton
            }
            .padding()
            .background(Color("PopupBackground"))
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
    
    private var recordingView: some View {
        VStack {
            VStack(alignment: .leading) {
                TextField("Recording Name", text: $recordingViewModel.recordingName)
                    .fontWeight(.semibold)
                VStack {
                    HStack {
                        Text(recordingViewModel.recordingParentTitle)
                        Spacer()
                        Button("Set Location") {
                            recordingViewModel.updateParentFolder(parentID: viewModel.currentFolder?.id, folderTitle: viewModel.currentFolderTitle)
                        }
                    }
                    Text("\(recordingViewModel.formattedcurrentDuration)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(Color("PopupBackground"))
    }
    
    private var sortPicker: some View {
        Picker("Sort", selection: $viewModel.sortType) {
            ForEach(SortType.allCases, id: \.self) {
                Text($0.toString())
            }
        }
        .pickerStyle(.menu)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal)
    }
    
    private var folderList: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                Group {
                    if item is Folder {
                        createListRow(item: item)
                    } else {
                        createListRow(item: item)
                            .background(
                                NavigationLink {
                                    PlaybackView(recording: item as! AudioRecording)
                                } label: {}.opacity(0)
                                    .disabled(recordingViewModel.isRecording)
                            )
                    }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        
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
        }
    }
    
    // TODO: REMOVE - TESTING ONLY
    private func testRecord() {
        recordingViewModel.isRecording.toggle()
    }
    
    private var recordButton: some View {
        Button {
            withAnimation {
                testRecord() // TODO: REMOVE - TESTING ONLY
                if recordingViewModel.isRecording {
                    recordingViewModel.stopRecording()
                    viewModel.loadItems(atFolderID: viewModel.currentFolder?.id)
                } else {
                    recordingViewModel.startRecording(parentID: viewModel.currentFolder?.id, folderTitle: viewModel.currentFolderTitle)
                }
            }
        } label: {
            Image(systemName: "waveform.circle")
                .resizable()
                .foregroundStyle(recordingViewModel.isRecording ? .red : .blue)
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
    let f = AudioRecording(name: "A really long name for a recording, let see how far it spills over!", date: Date(), duration: 123, recordingURL: URL(string: "www.sample.com")!)
    return FolderListView(database: MockDataManager(folders: MockDataManager.sampleFolders, files: [f]))
}
