//
//  MoveItemView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/26/24.
//

import SwiftUI

struct MoveItemView: View {
    @ObservedObject var viewModel: MoveItemViewModel
    let editingItem: Item
    @Binding var isPresenting: Bool
    let moveAction: (UUID?) -> Void
        
    init(editingItem: Item, database: DataManager, isPresenting: Binding<Bool>, moveAction: @escaping (UUID?) -> Void) {
        self.viewModel = MoveItemViewModel(database: database)
        self.editingItem = editingItem
        self._isPresenting = isPresenting
        self.moveAction = moveAction
    }
    
    var body: some View {
        ZStack {
            
            NavigationStack {
                List {
                    ForEach(viewModel.items, id: \.id) { item in
                        Group {
                            TappableListRow(name: item.name,
                                    icon: item.icon,
                                    item: item,
                                    onListRowTap: viewModel.setFolder)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(viewModel.currentFolderTitle)
                .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()} )
                .toolbar {
                    ToolbarItemGroup(placement: .automatic) {
                        Button("Cancel") { isPresenting = false }
                    }
                }
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            .onAppear {
                viewModel.handleOnAppear()
            }
            
            VStack {
                // TODO: can't move a folder to inside itself
                Button {
                    moveAction(viewModel.currentFolder?.id ?? nil)
                    isPresenting = false
                } label: {
                    Text("Move")
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.pink)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding()
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

#Preview {
    MoveItemView(editingItem: Folder(name: "Folder A"),
                 database: MockDataManager(folders: MockDataManager.sampleFolders,
                                           files: MockDataManager.sampleFiles), 
                 isPresenting: .constant(true), 
                 moveAction: {UUID in })
}
