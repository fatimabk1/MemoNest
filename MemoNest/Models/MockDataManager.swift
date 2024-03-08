//
//  MockDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

// conforms to protocol, concrete implementation
// TODO: add Realm implementation with real data
final class MockDataManager: DataManager {
    
    private var files: [File]
    private var folders: [Folder]
    
    init() {
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folderAA1 = Folder(name: "Folder AA1", parent: folderA.id)
        let folderAA2 = Folder(name: "Folder AA2", parent: folderA.id)
        let folderAAA1 = Folder(name: "Folder AAA1", parent: folderAA1.id)
        self.folders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
        let fileAA1 = File(name: "File in Folder AA1", folder: folderAA1.id)
        let fileAA2 = File(name: "File in Folder AA2", folder: folderAA2.id)
        let fileAAA1 = File(name: "File in Folder AAA1", folder: folderAAA1.id)
        self.files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
    }
    
    internal func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.removeAll(where: {$0.id == folderID})
            completion()
        }
    }
    
    // MARK: folder functions
    func fetchFolders(parentID: UUID?, completion: @escaping ([Folder]) -> Void) {
        DispatchQueue.global().async { [weak self] in
            completion((self?.folders ?? []).filter({$0.parent == parentID}))
        }
    }
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.append(Folder(name: folderName, parent: parent))
            completion()
        }
    }
    
    // recursive remove folder w/in async blocks
    func removeFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else {return}
            
            var foldersToDelete: [UUID] = [folderID]
            processFolder()
            
            func processFolder() {
                guard !foldersToDelete.isEmpty else {
                    completion()
                    return
                }
                
                let folderID = foldersToDelete.removeFirst()
                
                // fetch folders, then append to delete list, then delete parent folder
                self.fetchFolders(parentID: folderID) { folders in
                    for folder in folders {
                        foldersToDelete.append(folder.id)
                    }
                    self.removeSingleFolder(folderID: folderID) {
                        // process next folder after removing current folder to ensure
                        // UI refreshes after folder is deleted
                        processFolder()
                    }
                   
                }
                // IN-PARALLEL: fetch files, then remove files
                self.fetchFiles(parentID: folderID) { files in
                    for file in files {
                        self.removeFile(fileID: file.id) {}
                    }
                }
                
            }
        }
    }
    
    private func printLibraryContents() {
        print("\nLIBRARY:")
        for folder in folders {
            print(folder.name)
        }
        for file in files {
            print(file.name)
        }
    }
    
    private func printRemovalList(folderIDs: [UUID]) {
        print("\nRemoval list:")
        for f in folderIDs {
            print(self.folders.filter({$0.id == f}).first?.name ?? "NO match")
        }
    }
    
    func moveFolder(folderID: UUID, newParentID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.folders.firstIndex(where: {$0.id == folderID})
            guard let index else { return }
            
            var folder = self.folders[index]
            folder.parent = newParentID
            self.folders[index] = folder
            completion()
        }
    }
    func renameFolder(folderID: UUID, name: String, completion: @escaping () -> Void){
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.folders.firstIndex(where: {$0.id == folderID})
            guard let index else { return }
            
            var folder = self.folders[index]
            folder.name = name
            self.folders[index] = folder
            completion()
        }
    }
    func fetchSingleFolder(folderID: UUID?, completion: @escaping (Folder?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let folderID {
                let parentFolder = folders.first(where: {$0.id == folderID})
                completion(parentFolder)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: file functions
    func fetchFiles(parentID: UUID?, completion: @escaping ([File]) -> Void ) {
        completion(files.filter({$0.folder == parentID}))
    }
    func addFile(fileName: String, folderID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let file = File(name: fileName, folder: folderID)
            self?.files.append(file)
            completion()
        }
    }
    func removeFile(fileID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            files.removeAll(where: {$0.id == fileID})
            completion()
        }
    }
    func moveFile(fileID: UUID, newFolderID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.files.firstIndex(where: {$0.id == fileID})
            guard let index else { return }
            
            var file = self.files[index]
            file.folder = newFolderID
            self.files[index] = file
            completion()
        }
    }
    func renameFile(fileID: UUID, name: String, completion: @escaping () -> Void){
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.files.firstIndex(where: {$0.id == fileID})
            guard let index else { return }
            
            var file = self.files[index]
            file.name = name
            self.files[index] = file
            completion()
        }
    }
}
