//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

final class FolderListViewModel: ObservableObject {
    @Published var currentFolder: Folder?
    @Published var items = [NameIconProtocol]()
    @Published var playbackFile: File?
    @Published var hasPlaybackFile = false
    
    // MARK: computed properties
    var currentFolderID: UUID? {
        return currentFolder?.id
    }
    var currentFolderTitle: String {
        return currentFolder?.name ?? "Library"
    }
    
    init() {}
    
    private func fetchCurrentItems(from parent: UUID?) {
        DataManager.shared.fetchFolders(parentID: currentFolderID) { [weak self] folders in
            DataManager.shared.fetchFiles(parentID: self?.currentFolderID) { files in
                DispatchQueue.main.async {
                    self?.items = folders + files // logic in VM for ordering, etc
                }
            }
        }
    }
    
    func handleOnAppear() {
        fetchCurrentItems(from: nil)
    }
    
    func navigateToFolder(folder: Folder) {
        currentFolder = folder
        self.fetchCurrentItems(from: currentFolderID)
    }
    
    func setPlaybackFile(file: File) {
        self.playbackFile = file
        self.hasPlaybackFile = true
    }
    
    // MARK: folder functions
    func addFolder(folderName: String = "New Folder") {
        DataManager.shared.addFolder(folderName: folderName, parent: currentFolderID) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func removeFolder(folder: Folder) {
        DataManager.shared.removeFolder(folderID: folder.id) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func moveFolder(folder: Folder, destination: Folder) {
        DataManager.shared.moveFolder(folderID: folder.id, newParentID: destination.id) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func renameFolder(folder: Folder, name: String) {
        DataManager.shared.renameFolder(folderID: folder.id, name: name) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    
    // MARK: file functions
    func addFile(fileName: String = "New File") {
        DataManager.shared.addFile(fileName: fileName, folderID: self.currentFolderID) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func removeFile(file: File) {
        DataManager.shared.removeFile(fileID: file.id) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func moveFile(file: File, destination: Folder) {
        DataManager.shared.moveFile(fileID: file.id, newFolderID: destination.id) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
    func renameFile(file: File, fileName: String) {
        DataManager.shared.renameFile(fileID: file.id, name: fileName) {
            self.fetchCurrentItems(from: self.currentFolderID)
        }
    }
}
