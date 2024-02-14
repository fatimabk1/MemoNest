//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

final class FolderListViewModel: ObservableObject {
    @Published var currentFolder: UUID? = nil
    @Published var currentFolderTitle = "Library"
    @Published var items = [NameIconProtocol]()
    
    init() {
        
    }
    
    private func fetchCurrentItems(from parent: UUID?) {
        DataManager.shared.fetchFolders(parentID: currentFolder) { [weak self] folders in
            DataManager.shared.fetchFiles(parentID: self?.currentFolder) { files in
                DispatchQueue.main.async {
                    self?.items = folders + files // logic in VM for ordering, etc
                }
            }
        }
        
    }
    
    func handleOnAppear() {
        fetchCurrentItems(from: nil)
    }
    
    // MARK: folder functions
    func addFolder() {
        // create new DB folder & push to DB
        // fetch current items (refresh source of truth data) - ensures data consistency
        
        let folderName = "new folder"
        let parent: UUID? = nil
        DataManager.shared.addFolder(folderName: folderName, parent: parent) {
            self.fetchCurrentItems(from: parent)
        }
    }
    func removeFolder(_ folder: Folder) {}
    func moveFolder() {}
    func renameFolder() {}
    
    // MARK: file functions
    func addFile() {}
    func removeFile() {}
    func moveFile() {}
    func renameFile() {}
}
