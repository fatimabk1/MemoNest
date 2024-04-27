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
    @Published var currentFolder: Item?
    @Published var hasError = false
    @Published var error: TitledError?
    private let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    let moveItem: Item

    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    init(moveItem: Item, database: DataManager, queue: DispatchQueue = .main) {
        self.moveItem = moveItem
        self.database = database
        self.queue = queue
    }
    
    private func handleError(completionStatus: Subscribers.Completion<DatabaseError>) {
        if case let .failure(error) = completionStatus {
            self.hasError = true
            self.error = error
        }
    }
    
    func itemIsMoveItem(item: Item) -> Bool {
        item.id == moveItem.id
    }
    
    func setFolder(item: Item){
        guard item.isFolder() else { return }
        loadFolders(atFolderID: item.id)
    }
    
    func loadFolders(atFolderID folderID: UUID?) {
        if let folderID {
            database.fetchFolderInfo(folderID: folderID)
                .receive(on: queue)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] folder in
                    self?.currentFolder = folder
                    print("Updated load folder: \(String(describing: self?.currentFolder?.name))" )
                })
                .store(in: &cancellables)
        }
        
        database.fetchFolders(parentID: folderID)
            .receive(on: queue)
            .sink (
                receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] folders in
                    self?.items = folders
                }
            )
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
