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
        VStack(spacing: 0) {
//            NavigationStack {
                folderList
//                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(viewModel.currentFolderTitle)
                    .navigationBarItems(leading: BackButton(hasParentFolder: viewModel.hasParent) {viewModel.goBack()} )
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(viewModel.currentFolderTitle)
                                .foregroundColor(Colors.mainText)
                                .customFont(style: .body, fontWeight: .bold)
                        }
                        ToolbarItemGroup(placement: .automatic) {
                            Button {
                                isPresenting = false
                            } label: {
                                Text("Cancel")
                                    .foregroundStyle(Colors.blueMedium)
                                    .customFont(style: .body)
                            }
                        }
                    }
//            }
            .onAppear {
                viewModel.handleOnAppear()
            }
            .alert(isPresented: $viewModel.hasError) {
                Alert(title: Text("\(viewModel.error?.title ?? "")"))
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
                    .listRowBackground(Color.clear)
                .disabled(isMoveItem ? true : false)
                .foregroundStyle(isMoveItem ? .gray : .primary)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .background(Colors.background)
        .frame(maxHeight: .infinity)
    }
    
    var moveButton: some View {
        Button {
            moveAction(viewModel.currentFolder?.id ?? nil)
            isPresenting = false
        } label: {
            Text("Move")
                .customFont(style: .body)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Colors.blueMedium)
                .foregroundStyle(Colors.mainText)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding()
        .background(Colors.background)
    }
}

#Preview {
    NavigationStack {
        MoveItemView(moveItem: MockDataManager.folderA,
                     database: MockDataManager(folders: MockDataManager.sampleFolders,
                                               files: MockDataManager.sampleFiles),
                     isPresenting: .constant(true),
                     moveAction: {UUID in })
    }
}
