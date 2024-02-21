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
        if let memo = viewModel.playbackFile {
            PlayBackView(file: memo)
        } else {
            ZStack {
                NavigationStack {
                    TitleBar(viewModel: viewModel)
                    List {
                        ForEach(viewModel.items, id: \.id) { item in
                            if item is Folder {
                                ListRow(name: item.name, icon: item.icon) {
                                    viewModel.navigateToFolder(folder: item as! Folder)
                                }
                            } else {
                                NavigationLink {
                                    PlayBackView(file: item as! File)
                                } label: {
//                                    Text(item.name)
                                    ListRow(name: item.name, icon: item.icon) {}
                                }
                            }
                        }
                    }
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        viewModel.handleOnAppear()
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
                }
                //            if viewModel.hasPlaybackFile {
                //                if let file = viewModel.playbackFile {
                //                    PlayBackView(file: file)
                //                }
                //            }
            }
        }
    }
}

struct TitleBar: View {
    @ObservedObject var viewModel: FolderListViewModel
    
    var body: some View {
        HStack {
            if viewModel.currentFolder != nil {
                Button {
                    viewModel.navigateToParentFolder()
                } label: {
                    Text("<")
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                }
            }
            Text(viewModel.currentFolderTitle)
                .font(.largeTitle)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    FolderListView()
}
