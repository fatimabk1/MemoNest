//
//  MoveItemViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/27/24.
//

import Foundation
import Combine


final class MoveItemViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var currentFolder: Folder?
    private let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    let moveItem: Item

    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    // TODO: swap w/Realm
    // TODO: REMOVE - TEMP FILES/FOLDERS for development
    init(moveItem: Item, database: DataManager, queue: DispatchQueue = .main) {
        self.moveItem = moveItem
        self.database = database
        self.queue = queue
    }
    
    func itemIsMoveItem(item: Item) -> Bool {
        item.id == moveItem.id
    }
    
    func setFolder(item: Item){
        guard item is Folder else { return }
        loadFolders(atFolderID: item.id)
    }
    
    func loadFolders(atFolderID folderID: UUID?) {
        database.fetchFolderInfo(folderID: folderID)
            .receive(on: queue)
            .sink { [weak self] folder in
                guard let self else { return }
                self.currentFolder = folder
            }
            .store(in: &cancellables)
        
        database.fetchFolders(parentID: folderID)
            .receive(on: queue)
            .sink { [weak self] folders in
                self?.items = folders
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        self.loadFolders(atFolderID: currentFolder?.id)
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadFolders(atFolderID: currentFolder.parent)
    }
}
