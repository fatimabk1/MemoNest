//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine

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
    private var cancellables = Set<AnyCancellable>()
    
        
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
    
    func setFolder(folder: Folder){
        currentFolder = folder
        loadItems(atFolderID: currentFolderID)
    }
    
    func loadItems(atFolderID folderID: UUID?) {
        database.fetchFolders(parentID: folderID)
            .zip(database.fetchFiles(parentID: folderID))
            .sink { [weak self] folders, files in
                self?.items = folders + files
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        self.loadItems(atFolderID: currentFolderID)
    }
    
    func renameItem(item: Item, name: String) {
        if item is Folder {
            database.renameFolder(folderID: item.id, name: name)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
        } else {
            database.renameFile(fileID: item.id, name: name)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
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
            database.removeFolder(folderID: item.id)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
        } else {
            database.removeFile(fileID: item.id)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
        }
    }
    
    
    func moveItem(item: Item, destinationFolderID folderID: UUID) {
        if item is Folder {
            database.moveFolder(folderID: item.id, newParentID: folderID) 
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
        
        } else {
            database.moveFile(fileID: item.id, newParentID: folderID)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolderID)
                }
                .store(in: &cancellables)
        }
    }
    
    func addFile(fileName: String = "New File") {
        database.addFile(fileName: fileName, parentID: self.currentFolderID)
            .sink { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
            .store(in: &cancellables)
    }
    
    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parentID: currentFolderID)
            .sink { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolderID)
            }
            .store(in: &cancellables)
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
