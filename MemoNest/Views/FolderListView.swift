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
    
    init(currentFolder: Folder?) {
        self.viewModel = FolderListViewModel(currentFolder: currentFolder)
    }
    // cannot move a folder to inside itself -- have a check for this (circular folder reference)
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.items, id: \.id) { item in
                    Group {
                        if item is Folder {
//                            Button {
////                                print("folder clicked")
////                                viewModel.loadItems(atFolderID: item.id)
//                                
//                            } label: {
//                               
//                            }
                            createListRow(item: item)
                                .onTapGesture(perform: { viewModel.loadItems(atFolderID: item.id) })
                        } else {
                            NavigationLink {
                                PlayBackView(file: item as! File)
                            } label: {
                                createListRow(item: item)
                            }
                        }
                    }
                }
              }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.currentFolderTitle)
            .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.currentFolder != nil) {viewModel.goBack()} )
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
                    //                    Button {
                    //                        isPresentingAddEditor = true
//                    } label: {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 30, height: 30)
//                    }
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
//        .sheet(isPresented: $isPresentingAddEditor) {
//            RenameItemPopup(name: "folder", icon: "folder") { newName in
//                 viewModel.renameItem(item: item, name: newName)
//            }
//            .presentationDetents([.medium])
//        }
    }
    
    func createListRow(item: Item) -> some View {
        ListRow(name: item.name, icon: item.icon) { action in
            switch action {
            case .rename:
                print("Clicked rename")
//                RenameItemPopup { newName in
//                    viewModel.renameItem(item: item, name: newName)
//                }
            case .delete:
                viewModel.removeItem(item: item)
            }
        }
    }
    
//    func handleRowAction(action: RowAction, item: Item) {
//        switch action {
//        case .rename:
//            print("Clicked rename")
////            RenameItemPopup { newName in
////                viewModel.renameItem(item: item, name: newName)
////            }
//        case .delete:
//            viewModel.removeItem(item: item)
//        }
//    }
    
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
    FolderListView(currentFolder: nil)
}
