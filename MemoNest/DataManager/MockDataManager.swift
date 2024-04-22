//
//  MockDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine


final class MockDataManager: DataManager {
    var files = [Item]()
    var folders = [Item]()
    var cancellables = Set<AnyCancellable>()
    let queue =  DispatchQueue.global(qos: .userInitiated)
    
    init(folders: [Item] = [], files: [Item] = []) {
        self.folders = folders
        self.files = files
    }
    
    // MARK: fetch
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError>  {
        return Future<Item?, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                print(self.queue)
                promise(.success(self.folders.first(where: {$0.id == folderID})))
            }
        }
        .eraseToAnyPublisher()
    }
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        Future<[Item], DatabaseError> { promise in
            self.queue.async { [weak self] in
                promise(.success(self?.files.filter({$0.parent == parentID}) ?? []))
            }
        }
        .eraseToAnyPublisher()
    }
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        Future<[Item], DatabaseError> { promise in
            self.queue.async { [weak self] in
                promise(.success((self?.folders ?? []).filter({$0.parent == parentID})))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
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
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
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
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
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
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
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
    
    // MARK: add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                self?.folders.append(Item(name: folderName, parent: parentID, type: .folder))
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func 
    addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                let audioInfo = AudioMetaData(duration: duration, recordingURLFileName: recordingURLFileName)
                let file = Item(name: fileName, parent: parentID, date: date, type: .recording, audioInfo: audioInfo)
                self?.files.append(file)
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: remove
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError>{
        self.fetchFolders(parentID: folderID)
        // handle child folders
            .flatMap { [weak self] childFolders -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let childFolderDeletions = childFolders.compactMap { self.removeFolder(folderID: $0.id) } // recursive delete each child folder
                return Publishers.MergeMany(childFolderDeletions) // merge into a single event stream
                    .collect() // wait for all async deletions to finish
                    .map { _ in () } // transform output to void to match AnyPublisher type
                    .eraseToAnyPublisher()
            }
        // fetch files
            .flatMap { [weak self] _ -> AnyPublisher<[Item], DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.fetchFiles(parentID: folderID)
            }
        // delete files
            .flatMap { [weak self] files  -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeAll(ids: files.map({$0.id}))
            }
        // delete folder itself
            .flatMap { [weak self] _  -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeSingleFolder(folderID: folderID)
            }
        .eraseToAnyPublisher()
    }
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                folders.removeAll(where: {$0.id == folderID})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func removeFile(fileID: UUID) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                files.removeAll(where: {$0.id == fileID})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                files.removeAll(where: {ids.contains($0.id)})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension MockDataManager {
    static let folderA = Item(name: "Folder A", type: .folder)
    static let folderB = Item(name: "Folder B", type: .folder)
    static let folderC = Item(name: "Folder C", type: .folder)
    static let folderAA1 = Item(name: "Folder AA1", parent: folderA.id, type: .folder)
    static let folderAA2 = Item(name: "Folder AA2", parent: folderA.id, type: .folder)
    static let folderAAA1 = Item(name: "Folder AAA1", parent: folderAA1.id, type: .folder)
    static let sampleFolders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
    
    static let audioInfo = AudioMetaData(duration: 0, recordingURLFileName: "www.sample.com")
    static let audio1 = Item(name: "File1 in Library",
                             date: Date(), type: .recording, audioInfo: audioInfo)
    static let audio2 = Item(name: "File2 in Library",
                                       date: Date(), type: .recording, audioInfo: audioInfo)
    static let audio3 = Item(name: "File3 in Library",
                                       date: Date(), type: .recording, audioInfo: audioInfo)
    static let audioA1 = Item(name: "File in Folder A",
                              parent: folderA.id, date: Date(), type: .recording, audioInfo: audioInfo)
    static let audioAA1 = Item(name: "File in Folder AA1",
                               parent: folderAA1.id, date: Date(), type: .recording, audioInfo: audioInfo)
    static let audioAA2 = Item(name: "File in Folder AA2",
                               parent: folderAA2.id, date: Date(), type: .recording, audioInfo: audioInfo)
    static let audioAAA1 = Item(name: "File in Folder AAA1",
                                parent: folderAAA1.id, date: Date(), type: .recording, audioInfo: audioInfo)
    static let sampleFiles = [audio1, audio2, audio3, audioA1, audioAA1, audioAA2, audioAAA1]
}
