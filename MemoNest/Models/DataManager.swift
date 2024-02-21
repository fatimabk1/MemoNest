//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

// conforms to protocol, concrete implementation
// TODO: write protocol w/functions, vars
// TODO: add Realm implementation with real data
final class DataManager {
    private var files: [File] // TODO, SHOULD BE DB
    private var folders: [Folder]
    
    static let shared = DataManager()
    private init() {
        let folderA = Folder(name: "A")
        let folderB = Folder(name: "B")
        let folderC = Folder(name: "C")
        self.folders = [folderA, folderB, folderC]
        
        let file1 = File(name: "1")
        let file2 = File(name: "2")
        let file3 = File(name: "3")
        self.files = [file1, file2, file3]
    }
    
    private func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.removeAll(where: {$0.id == folderID})
            completion()
        }
    }
    
    // MARK: folder functions
    func fetchFolders(parentID: UUID?, completion: @escaping ([Folder]) -> Void) {
        completion(folders.filter({$0.parent == parentID}))
    }
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.append(Folder(name: folderName, parent: parent))
            completion()
        }
    }
    func removeFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var removalList = [UUID]()
            var nestedFolders = [UUID]()
            removalList.append(folderID)
            nestedFolders.append(folderID)
            
            // BFS compile list of all nested folders under folder to delete
            while !nestedFolders.isEmpty {
                let fid = nestedFolders.removeFirst()
                self.fetchFolders(parentID: fid) { folders in
                    for folder in folders {
                        removalList.append(folder.id)
                        nestedFolders.append(folder.id)
                    }
                }
            }
            
            // delete files within each folder to be deleted
            for fid in removalList {
                self.fetchFiles(parentID: fid) { files in
                    for file in files {
                        self.removeFile(fileID: file.id) {}
                    }
                }
            }
            
            // delete folders
            for fid in removalList {
                self.fetchFolders(parentID: fid) { folders in
                    for folder in folders {
                        self.removeSingleFolder(folderID: folder.id) {}
                    }
                }
            }
            completion()
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
            self?.files.removeAll(where: {$0.id == fileID})
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
