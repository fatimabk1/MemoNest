//
//  MoveItemView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/26/24.
//

import SwiftUI

struct MoveItemView: View {
    @ObservedObject var viewModel: MoveItemViewModel

    @Binding var isPresenting: Bool
    let moveAction: (UUID?) -> Void
    
    init(moveItem: Item, database: DataManager, isPresenting: Binding<Bool>, moveAction: @escaping (UUID?) -> Void) {
        self.viewModel = MoveItemViewModel(moveItem: moveItem, database: database)
        self._isPresenting = isPresenting
        self.moveAction = moveAction
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                folderList
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(viewModel.currentFolderTitle)
                    .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()} )
                    .toolbar {
                        ToolbarItemGroup(placement: .automatic) {
                            Button("Cancel") { isPresenting = false }
                        }
                    }
            }
            .onAppear {
                viewModel.handleOnAppear()
            }
            moveButton
        }
    }
    
    var folderList: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                let isMoveItem = viewModel.itemIsMoveItem(item: item)
                TappableListRow(item: item,
                                onListRowTap: viewModel.setFolder)
                .disabled(isMoveItem ? true : false)
                .foregroundStyle(isMoveItem ? .gray : .primary)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }
    
    var moveButton: some View {
        Button {
            moveAction(viewModel.currentFolder?.id ?? nil)
            isPresenting = false
        } label: {
            Text("Move")
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(.blue.opacity(0.5))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    MoveItemView(moveItem: MockDataManager.folderA,
                 database: MockDataManager(folders: MockDataManager.sampleFolders,
                                           files: MockDataManager.sampleFiles),
                 isPresenting: .constant(true),
                 moveAction: {UUID in })
}
