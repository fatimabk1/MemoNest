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

struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    
    init(database: DataManager) {
        self.viewModel = FolderListViewModel(database: database)
    }

    var body: some View {
        ZStack {
            NavigationStack {
                folderList
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(viewModel.currentFolderTitle)
                    .toolbar {
                        ToolbarItemGroup(placement: .topBarLeading) {
                            BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()}
                        }
                        ToolbarItemGroup(placement: .bottomBar) {
                            Spacer()
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
                    }
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
            addRenameInputView
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
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
                                NavigationLink("", destination: PlaybackViewPlaceHolder())
                                    .opacity(0)
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
    
    private func createListRow(item: Item) -> some View {
        TappableListRowWithMenu(name: item.name,
                icon: item.icon,
                item: item,
                onListRowTap: viewModel.setFolder) { action in
            
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
    FolderListView(database: MockDataManager(folders: MockDataManager.sampleFolders, files: MockDataManager.sampleFiles))
}
