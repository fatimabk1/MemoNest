//
//  FolderListView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI



struct FolderListView: View {
    @ObservedObject var viewModel: FolderListViewModel
    @State var isPresentingAddEditor = false
    @State var editingItem: Item? = nil
    
    init() {
        self.viewModel = FolderListViewModel()
    }
    // cannot move a folder to inside itself -- have a check for this (circular folder reference)
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    ForEach(viewModel.items, id: \.id) { item in
                        Group {
                            if item is Folder {
                                createListRow(item: item)
                            } else {
                                createListRow(item: item)
                                    .background(
                                        NavigationLink("", destination: PlayBackView(file: item as! File))
                                            .opacity(0)
                                    )
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(viewModel.currentFolderTitle)
                .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()} )
                .navigationBarItems(trailing: EditModeButton())
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Menu {
                            Button("Add File", action: {viewModel.addFile(fileName: "New File")})
                            Button("Add Folder", action: {viewModel.addFolder(folderName: "New Folder")}) // folder.fill.badge.plus
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
            if let item = editingItem {
                RenameItemPopup(name: item.name, dismiss: { editingItem = nil }) { newName in
                    viewModel.renameItem(item: item, name: newName)
                    editingItem = nil
                }
                .presentationDetents([.medium])
            }
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
    }
    
    func createListRow(item: Item) -> some View {
        ListRow(name: item.name,
                icon: item.icon,
                item: item,
                onListRowTap: viewModel.setFolder) { action in
            switch action {
            case .rename:
                editingItem = item
                isPresentingAddEditor = true
            case .delete:
                viewModel.removeItem(item: item)
            }
        }
    }
}



struct EditModeButton: View {
    var body: some View {
        Button {
            
        } label: {
            Text("Edit")
        }
    }
}


#Preview {
    FolderListView()
}
