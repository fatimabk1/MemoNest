//
//  MockDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine

// conforms to protocol, concrete implementation
// TODO: add Realm implementation with real data
// TODO: 


final class MockDataManager: DataManager {
    func removeFolder(folderID: UUID, completion: @escaping () -> Void) {
        //
    }
    
    func listContentRecursive(folderID: UUID, completion: @escaping ([UUID]) -> Void) {
        //
    }
    
    var files = [File]()
    var folders = [Folder]()
    
    init(folders: [Folder] = [], files: [File] = []) {
        self.folders = folders
        self.files = files
    }
    
    
    
    
    // fetch
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[File], Never> {
        Future<[File], Never> { promise in
            DispatchQueue.global().async { [weak self] in
                promise(.success(self?.files.filter({$0.folder == parentID}) ?? []))
            }
        }
        .eraseToAnyPublisher()
    }
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Folder], Never> {
        Future<[Folder], Never> { promise in
            DispatchQueue.global().async { [weak self] in
                promise(.success((self?.folders ?? []).filter({$0.parent == parentID})))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // remove
//    func listContentRecursive(folderID: UUID) async -> [UUID] {
//        
//
//    }
    
    
//    func removeFolder(folderID: UUID, completion: @escaping () -> Void) {
//        DispatchQueue.global().async { [weak self] in
//            guard let self else {return}
//            var foldersToDelete: [UUID] = [folderID]
//            
//            func processFolder() {
//                guard !foldersToDelete.isEmpty else {
//                    completion()
//                    return
//                }
//                
//                let folderID = foldersToDelete.removeFirst()
//                
//                // fetch folders, then append to delete list, then delete parent folder
//                self.fetchFolders(parentID: folderID) { folders in
//                    for folder in folders {
//                        foldersToDelete.append(folder.id)
//                    }
//                    self.removeSingleFolder(folderID: folderID) {
//                        // process next folder after removing current folder to ensure
//                        // UI refreshes after folder is deleted
//                        processFolder()
//                    }
//                   
//                }
//                // IN-PARALLEL: fetch files, then remove files
//                self.fetchFiles(parentID: folderID) { files in
//                    for file in files {
//                        self.removeFile(fileID: file.id) {}
//                    }
//                }
//            }
//            
//            processFolder()
//        }
//    }

    func removeAll(ids: [UUID], completion: @escaping () -> Void) {
        //
    }
    func removeFile(fileID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            files.removeAll(where: {$0.id == fileID})
            completion()
        }
    }
    
    // rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                let index = self.folders.firstIndex(where: {$0.id == folderID})
                guard let index else { return }
                
                var folder = self.folders[index]
                folder.name = name
                self.folders[index] = folder
            }
        }
        .eraseToAnyPublisher()
    }
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                
                let index = self.files.firstIndex(where: {$0.id == fileID})
                guard let index else { return }
                
                var file = self.files[index]
                file.name = name
                self.files[index] = file
            }
        }
        .eraseToAnyPublisher()
    }
    
//    func renameFolder(folderID: UUID, name: String, completion: @escaping () -> Void){
//        DispatchQueue.global().async { [weak self] in
//            guard let self else { return }
//            
//            let index = self.folders.firstIndex(where: {$0.id == folderID})
//            guard let index else { return }
//            
//            var folder = self.folders[index]
//            folder.name = name
//            self.folders[index] = folder
//            completion()
//        }
//    }
//    func renameFile(fileID: UUID, name: String, completion: @escaping () -> Void){
//        DispatchQueue.global().async { [weak self] in
//            guard let self else { return }
//            
//            let index = self.files.firstIndex(where: {$0.id == fileID})
//            guard let index else { return }
//            
//            var file = self.files[index]
//            file.name = name
//            self.files[index] = file
//            completion()
//        }
//    }
//    
    // move
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
    
    // add
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.append(Folder(name: folderName, parent: parent))
            completion()
        }
    }
    func addFile(fileName: String, folderID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let file = File(name: fileName, folder: folderID)
            self?.files.append(file)
            completion()
        }
    }
    
   
        
    func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.removeAll(where: {$0.id == folderID})
            completion()
        }
    }
    

   
    
    // TODO: separate function for just deleting the folder the user can see; faster feedback for user
    // recursive remove folder w/in async blocks
    
    private func printLibraryContents() {
        print("\nLIBRARY:")
        for folder in folders {
            print(folder.name)
        }
        for file in files {
            print(file.name)
        }
    }
        
    
    func fetchSingleFolder(folderID: UUID?, completion: @escaping (Folder?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let folderID {
                let folder = folders.first(where: {$0.id == folderID})
                completion(folder)
            } else {
                completion(nil)
            }
        }
    }
}
