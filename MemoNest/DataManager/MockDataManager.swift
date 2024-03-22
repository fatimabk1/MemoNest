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
    var files = [File]()
    var folders = [Folder]()
    var cancellables = Set<AnyCancellable>()
    
    init(folders: [Folder] = [], files: [File] = []) {
        self.folders = folders
        self.files = files
    }
    
    // MARK: fetch
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[File], Never> {
        Future<[File], Never> { promise in
            DispatchQueue.global().async { [weak self] in
                promise(.success(self?.files.filter({$0.parent == parentID}) ?? []))
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
    
    // MARK: rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                let index = self.folders.firstIndex(where: {$0.id == folderID})
                guard let index else { return }
                
                var folder = self.folders[index]
                folder.name = name
                self.folders[index] = folder
                promise(.success(()))
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
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // MARK: move
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                
                let index = self.folders.firstIndex(where: {$0.id == folderID})
                guard let index else { return }
                
                var folder = self.folders[index]
                folder.parent = newParentID
                self.folders[index] = folder
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                
                let index = self.files.firstIndex(where: {$0.id == fileID})
                guard let index else { return }
                
                var file = self.files[index]
                file.parent = newParentID
                self.files[index] = file
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                self?.folders.append(Folder(name: folderName, parent: parentID))
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func addFile(fileName: String, parentID: UUID?) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                let file = File(name: fileName, parent: parentID)
                self?.files.append(file)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // MARK: remove
    /*
     func recursiveDelete(f)
     fetchFolders(f)
     .flatMap { childFolders in
     childFolders.map { recursiveDelete($0.id) }
     }
     .flatMap {
     
     }
     
     */
    
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, Never>{
        self.fetchFolders(parentID: folderID)
        // handle child folders
            .flatMap { [weak self] childFolders -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let childFolderDeletions = childFolders.compactMap { self.removeFolder(folderID: $0.id) } // recursive delete each child folder
                return Publishers.MergeMany(childFolderDeletions) // merge into a single event stream
                    .collect() // wait for all async deletions to finish
                    .map { _ in () } // transform output to void to match AnyPublisher type
                    .eraseToAnyPublisher()
            }
        // fetch files
            .flatMap { [weak self] _ -> AnyPublisher<[File], Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.fetchFiles(parentID: folderID)
            }
        // delete files
            .flatMap { [weak self] files  -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeAll(ids: files.map({$0.id}))
            }
        // delete folder itself
            .flatMap { [weak self] _  -> AnyPublisher<Void, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeSingleFolder(folderID: folderID)
            }
        .eraseToAnyPublisher()
    }
    
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                folders.removeAll(where: {$0.id == folderID})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func removeFile(fileID: UUID) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                files.removeAll(where: {$0.id == fileID})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, Never> {
        Future<Void, Never> { promise in
            DispatchQueue.global().async { [weak self] in
                guard let self else { return }
                files.removeAll(where: {ids.contains($0.id)})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
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
        
    

}
