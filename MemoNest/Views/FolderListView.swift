//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct FolderListView: View {
    @ObservedObject var viewModel = FolderListViewModel()
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach(viewModel.items, id: \.id) { item in
                        ListRow(name: item.name, icon: item.icon) {
                            if item is Folder {
                                viewModel.navigateToFolder(folder: item as! Folder)
                            } else {
                                viewModel.setPlaybackFile(file: item as! File)
                            }
                        }
                    }
                }
                .onAppear {
                    viewModel.handleOnAppear()
                }
                .navigationTitle(viewModel.currentFolderTitle)
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
            }
            if viewModel.hasPlaybackFile {
                if let file = viewModel.playbackFile {
                    PlayBackView(file: file)
                }
            }
        }
    }
}


#Preview {
    FolderListView()
}
