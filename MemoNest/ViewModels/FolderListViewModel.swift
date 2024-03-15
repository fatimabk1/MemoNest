//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

// TODO: make it so functions accept an Item
// check for file/folder HERE not in view or view model for better
// separation between view -> view model -> database manager -> model

final class FolderListViewModel: ObservableObject {
    @Published var currentFolder: Folder?
    @Published var items = [Item]()
    @Published var playbackFile: File?
    @Published var hasPlaybackFile = false
    
    private let database: DataManager
    private let queue: DispatchQueue
        
    // MARK: computed properties
    var currentFolderID: UUID? {
        return currentFolder?.id
    }
    var currentFolderTitle: String {
        return currentFolder?.name ?? "Library"
    }
    
    // TODO: swap w/Realm
    init(currentFolder: Folder?, database: DataManager = MockDataManager(), queue: DispatchQueue = .main) {
        self.currentFolder = currentFolder
        self.database = database
        self.queue = queue
    }

    
    func loadItems(atFolderID folderID: UUID?) {
    database.fetchFolders(parentID: currentFolderID) { [weak self] folders in
        self?.database.fetchFiles(parentID: self?.currentFolderID) { files in
            self?.queue.async {
                self?.items = folders + files // logic in VM for ordering, etc
            }
        }
    }
}
    
    func handleOnAppear() {
        self.loadItems(atFolderID: currentFolderID)
    }
    
    func renameItem(item: Item, name: String) {
        if item is Folder {
            database.renameFolder(folderID: item.id, name: name) { [weak self] in
                guard let self else { return }
                self.loadItems(atFolderID: self.currentFolderID)
            }
        } else {
            database.renameFile(fileID: item.id, name: name) { [weak self] in
                guard let self else { return }
                self.loadItems(atFolderID: self.currentFolderID)
            }
        }
    }
    
    func goBack() {
        guard let currentFolder else { return }
        if currentFolder.parent != nil {
            self.loadItems(atFolderID: currentFolder.parent)
        } else {
            self.loadItems(atFolderID: nil)
        }
    }
    
    func sort1() {}
    func sort2() {}
    
    func removeItem(item: Item) {
        if item is Folder {
            self.database.removeFolder(folderID: item.id) { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
//            self.database.listContentRecursive(folderID: item.id) { [weak self] fullDeleteList in
//                guard let self else { return }
//                self.database.removeAll(ids: fullDeleteList) {
//                    self.loadItems(atFolderID: self.currentFolderID)
//                }
//            }
        } else {
            self.database.removeFile(fileID: item.id) { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
        }
    }
    
    func moveItem(item: Item, destinationFolderID folderID: UUID) {
        if item is Folder {
            database.moveFolder(folderID: item.id, newParentID: folderID) { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
        } else {
            database.moveFile(fileID: item.id, newFolderID: folderID) { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
        }
    }
    
    func addFile(fileName: String = "New File") {
        database.addFile(fileName: fileName, folderID: self.currentFolderID) { [weak self] in
            self?.loadItems(atFolderID: self?.currentFolderID)
        }
    }
    
    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parent: currentFolderID) { [weak self] in
            self?.loadItems(atFolderID: self?.currentFolderID)
        }
    }
    
    func setPlaybackFile(item: Item) {
        if item is File {
            self.playbackFile = (item as! File)
            self.hasPlaybackFile = true
        }
    }
    
    
    
    
//    func navigateToFolder(item: Item?) {
//        if let folder = item as? Folder {
//            currentFolder = folder
//            self.fetchCurrentItems(fromID: currentFolderID)
//        }
//    }
//    func navigateToParentFolder() {
//        guard let currentFolder else { return }
//        database.fetchSingleFolder(folderID: currentFolder.parent) { [weak self] parentFolder in
//            guard let self else { return }
//            queue.async {
//                self.currentFolder = parentFolder
//                self.fetchCurrentItems(fromID: self.currentFolderID)
//            }
//        }
//    }
//   
    
    // MARK: folder functions
    
//    func moveFolder(folder: Folder, destination: Folder) {
//        database.moveFolder(folderID: folder.id, newParentID: destination.id) {
//            self.fetchCurrentItems(fromID: self.currentFolderID)
//        }
//    }
//    func renameFolder(folder: Folder, name: String) {
//        database.renameFolder(folderID: folder.id, name: name) {
//            self.fetchCurrentItems(fromID: self.currentFolderID)
//        }
//    }
//    
//    // MARK: file functions
//    
//    func moveFile(file: File, destination: Folder) {
//        database.moveFile(fileID: file.id, newFolderID: destination.id) {
//            self.fetchCurrentItems(fromID: self.currentFolderID)
//        }
//    }
//    func renameFile(file: File, fileName: String) {
//        database.renameFile(fileID: file.id, name: fileName) {
//            self.fetchCurrentItems(fromID: self.currentFolderID)
//        }
//    }
}
