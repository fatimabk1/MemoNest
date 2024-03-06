//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

final class FolderListViewModel: ObservableObject {
    @Published var currentFolder: Folder?
    @Published var items = [Item]()
    @Published var playbackFile: File?
    @Published var hasPlaybackFile = false
    
    let database: DataManager
        
    // MARK: computed properties
    var currentFolderID: UUID? {
        return currentFolder?.id
    }
    var currentFolderTitle: String {
        return currentFolder?.name ?? "Library"
    }
    
    init(currentFolder: Folder?, database: DataManager) {
        self.currentFolder = currentFolder
        self.database = database
    }
    
    private func fetchCurrentItems(fromID parent: UUID?) {
        database.fetchFolders(parentID: currentFolderID) { [weak self] folders in
            self?.database.fetchFiles(parentID: self?.currentFolderID) { files in
                DispatchQueue.main.async {
                    self?.items = folders + files // logic in VM for ordering, etc
                }
            }
        }
    }
    
    func handleOnAppear() {
        fetchCurrentItems(fromID: currentFolderID)
    }
    func navigateToFolder(folder: Folder?) {
        currentFolder = folder
        self.fetchCurrentItems(fromID: currentFolderID)
    }
    func navigateToParentFolder() {
        guard let currentFolder else { return }
        database.fetchSingleFolder(folderID: currentFolder.parent) { [weak self] parentFolder in
            guard let self else { return }
            self.currentFolder = parentFolder
            self.fetchCurrentItems(fromID: currentFolderID)
        }
    }
    func setPlaybackFile(file: File) {
        self.playbackFile = file
        self.hasPlaybackFile = true
    }
    
    func removeItem(atIndices: IndexSet) {
        for index in atIndices { // TODO always take the first index for security reasons
            let item = items[index]
            if item is Folder {
                self.removeFolder(folder: item as! Folder)
            } else {
                self.removeFile(file: item as! File)
            }
        }
    }
    
    
    // MARK: folder functions
    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parent: currentFolderID) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    private func removeFolder(folder: Folder) {
        database.removeFolder(folderID: folder.id) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    func moveFolder(folder: Folder, destination: Folder) {
        database.moveFolder(folderID: folder.id, newParentID: destination.id) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    func renameFolder(folder: Folder, name: String) {
        database.renameFolder(folderID: folder.id, name: name) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    
    // MARK: file functions
    func addFile(fileName: String = "New File") {
        database.addFile(fileName: fileName, folderID: self.currentFolderID) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    private func removeFile(file: File) {
        database.removeFile(fileID: file.id) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    func moveFile(file: File, destination: Folder) {
        database.moveFile(fileID: file.id, newFolderID: destination.id) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
    func renameFile(file: File, fileName: String) {
        database.renameFile(fileID: file.id, name: fileName) {
            self.fetchCurrentItems(fromID: self.currentFolderID)
        }
    }
}
