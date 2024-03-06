//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    
    init(currentFolder: Folder?, database: DataManager) {
        self.viewModel = FolderListViewModel(currentFolder: currentFolder, database: database)
    }
    
    // cannot move a folder to inside itself -- have a check for this (circular folder reference)
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items, id: \.id) { item in
                    Group {
                        if item is Folder {
                            Button {
                                viewModel.navigateToFolder(folder: item as? Folder)
                            } label: {
                                ListRow(name: item.name, icon: item.icon)
                            }
                        } else {
                            NavigationLink {
                                PlayBackView(file: item as! File)
                            } label: {
                                ListRow(name: item.name, icon: item.icon)
                            }
                        }
                    }
                }
                .onDelete(perform: { indexSet in
                    print(indexSet)
                    viewModel.removeItem(atIndices: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.currentFolderTitle)
            .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.currentFolder != nil) {viewModel.navigateToParentFolder()} )
            .navigationBarItems(trailing: EditButton())
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("New Folder") { viewModel.addFolder() }
                    Button("New File") { viewModel.addFile() }
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
        
    }
    
}


struct BackButton: View {
    let hasParentFolder: Bool
    let backFunction: () -> Void
    
    var body: some View {
        if hasParentFolder {
            Button {
                backFunction()
            } label: {
                Image(systemName: "chevron.backward")
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    FolderListView(currentFolder: nil, database: MockDataManager())
}
