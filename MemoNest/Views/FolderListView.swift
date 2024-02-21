//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    
    init(currentFolder: Folder?) {
        self.viewModel = FolderListViewModel(currentFolder: currentFolder)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items, id: \.id) { item in
                    NavigationLink {
                        Group {
                            if item is Folder {
                                FolderListView(currentFolder: item as? Folder)
                            } else {
                                PlayBackView(file: item as! File)
                            }
                        }
                        .navigationTitle(item.name)
                    } label: {
                        ListRow(name: item.name, icon: item.icon)
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    viewModel.removeItem(atIndices: indexSet)
                })
                .onMove(perform: { indices, newOffset in
                    /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Code@*/ /*@END_MENU_TOKEN@*/
                })
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(viewModel.currentFolderTitle)
            }
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("New Folder") {
                        viewModel.addFolder()
                    }
                    
                    Button("New File") {
                        viewModel.addFile()
                    }
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


#Preview {
    FolderListView(currentFolder: nil)
}
