//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine



final class FolderListViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var currentFolder: Item?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var error: TitledError?
    
    @Published var sortType = SortType.dateAsc {
        didSet {
            let folders = items.filter({$0.isFolder()})
            let files = items.filter({$0.isAudio()})
            self.items = self.sortItems(folders) + self.sortItems(files)
        }
    }
    @Published var popup = PopupInput()
    @Published var itemAction: ItemAction? = nil
    @Published var editingItem: Item? = nil
    @Published var moveViewIsPresented = false {
        willSet {
            if newValue == false {
                self.setAction(action: .none, item: nil)
            }
        }
    }
    
    let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    init(database: DataManager, queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
    }
    
    // TODO: fix remaining switch in handleErrors -> if case let
    private func handleError(completionStatus: Subscribers.Completion<DatabaseError>) {
        if case let .failure(error) = completionStatus {
            self.hasError = true
            self.error = error
            print("Received error: \(error)")
        }
    }
    
    private func sortItems(_ items: [Item]) -> [Item] {
        switch sortType {
        case .dateAsc:
            return items.sortedByDateAsc()
        case .dateDesc:
            return items.sortedByDateDesc()
        case .name:
            return items.sortedByName()
        }
    }
        
    func setAction(action: ItemAction, item: Item?) {
        editingItem = item
        itemAction = action
        
        if itemAction == .rename {
            self.popup = PopupInput(popupTitle: "Rename",
                                    prompt: "Enter folder name",
                                    placeholder: editingItem?.name ?? "")
            return
        }
        
        if itemAction == ItemAction.add {
            self.popup = PopupInput(popupTitle: "Add Folder",
                                    prompt: "Enter folder name",
                                    placeholder: "New Folder")
            return
        }
    }
    
    func handleMenuTap(item: Item, action: ItemAction) {
        if action == .delete {
            removeItem(item: item)
        } else if action == .rename {
            setAction(action: action, item: item)
        } else if action == .move {
            setAction(action: action, item: item)
            moveViewIsPresented = true
        }
    }
    
    // MARK: - main logic
    // TODO: -- LESS GENERIC Name (UPDATE, change)
    func setFolder(item: Item){
        guard item.type == .folder else { return }
        loadItems(atFolderID: item.id)
    }
    
    func loadItems(atFolderID folderID: UUID?) {
        print("about to call fetch folder info")
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
        } else {
            self.currentFolder = nil
        }
        
        database.fetchFolders(parentID: folderID)
            .zip(database.fetchFiles(parentID: folderID))
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] folders, files in
                guard let self else { return }
                let sortedFolders = self.sortItems(folders)
                let sortedFiles = self.sortItems(files)
                self.items = sortedFolders + sortedFiles
                print("finished loading items")
                isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        print("starting load items")
        isLoading = true
        self.loadItems(atFolderID: currentFolder?.id)
        print(String(cString: __dispatch_queue_get_label(nil)))
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadItems(atFolderID: currentFolder.parent)
    }
    //FIXME: REMOVE if branch after cleaning up DB
    func renameItem(item: Item, name: String) {
        if item.isFolder() {
            database.renameFolder(folderID: item.id, name: name)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        } else {
            database.renameFile(fileID: item.id, name: name)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }
    
    func removeItem(item: Item) {
        if item.isFolder() {
            database.removeFolder(folderID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        } else {
            database.removeFile(fileID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }
    
    func moveItem(item: Item, destination: UUID?) {
        if item.isFolder() {
            database.moveFolder(folderID: item.id, newParentID: destination)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
            
        } else {
            database.moveFile(fileID: item.id, newParentID: destination)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }

    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parentID: currentFolder?.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            })
            .store(in: &cancellables)
    }
}
