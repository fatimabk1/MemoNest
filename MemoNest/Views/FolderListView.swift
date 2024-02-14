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
        List {
            ForEach(viewModel.items, id: \.id) { item in
                HStack {
                    Image(systemName: item.icon)
                    Text(item.name)
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
}

#Preview {
    FolderListView()
}
