//
//  MoveItemView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/26/24.
//

import SwiftUI
import Foundation
import Combine

final class MoveItemViewModel: ObservableObject {
    @Published var items = [Item]()
    
    private var currentFolder: Folder?
    private let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()

    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    // TODO: swap w/Realm
    // TODO: REMOVE - TEMP FILES/FOLDERS for development
    init(database: DataManager = MockDataManager(folders: MockDataManager.sampleFolders, files: MockDataManager.sampleFiles), queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
    }
    
    func setFolder(item: Item){
        guard item is Folder else { return }
        print("setting current Folder: \(item.name) [\(String(describing: item.id))]")
        loadItems(atFolderID: item.id)
    }
    
    func loadItems(atFolderID folderID: UUID?) {
        database.fetchFolderInfo(folderID: folderID)
            .receive(on: queue)
            .sink { [weak self] folder in
                guard let self else { return }
                self.currentFolder = folder
            }
            .store(in: &cancellables)
        
        database.fetchFolders(parentID: folderID)
            .zip(database.fetchFiles(parentID: folderID))
            .receive(on: queue)
            .sink { [weak self] folders, files in
                self?.items = folders + files
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        self.loadItems(atFolderID: currentFolder?.id)
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadItems(atFolderID: currentFolder.parent)
    }
}


struct MoveItemView: View {
    @ObservedObject var viewModel: MoveItemViewModel
    @State var isPresentingAddEditor = false
    @State var editingItem: Item? = nil
    @Binding var isMovingItem: Bool
    
    init(isMovingItem: Binding<Bool>) {
        self.viewModel = MoveItemViewModel()
        self._isMovingItem = isMovingItem
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
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
            // TODO: START HERE
//            .navigationBarItems(leading: Button("Cancel") {})
//            .toolbar {
//                ToolbarItemGroup(placement: .automatic) {
//                    Button("Cancel") {}
//                }
//            }
            .onAppear {
                viewModel.handleOnAppear()
            }
            VStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Move")
                        .padding()
                })
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
    MoveItemView(isMovingItem: .constant(true))
}
