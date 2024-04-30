//
//  MockDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine


final class MockDataManager: DataManager {
    var items = [Item]()
    var cancellables = Set<AnyCancellable>()
    let queue =  DispatchQueue.global(qos: .userInitiated)
    
    init(folders: [Item] = [], files: [Item] = []) {
        self.items = folders + files
    }
    
    // MARK: fetch
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError>  {
        return Future<Item?, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                promise(.success(self.items.first(where: {$0.id == folderID})))
            }
        }
        .eraseToAnyPublisher()
    }
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        Future<[Item], DatabaseError> { promise in
            self.queue.async { [weak self] in
                promise(.success(self?.items.filter({$0.parent == parentID && $0.isAudio()}) ?? []))
            }
        }
        .eraseToAnyPublisher()
    }
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        Future<[Item], DatabaseError> { promise in
            self.queue.async { [weak self] in
                promise(.success((self?.items ?? []).filter({$0.parent == parentID && $0.isFolder()})))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: rename
    func renameItem(itemID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                let index = self.items.firstIndex(where: {$0.id == itemID})
                guard let index else { return }
                
                var item = self.items[index]
                item.name = name
                self.items[index] = item
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: move
    func moveItem(itemID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                
                let index = self.items.firstIndex(where: {$0.id == itemID})
                guard let index else { return }
                
                var item = self.items[index]
                item.parent = newParentID
                self.items[index] = item
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                self?.items.append(Item(name: folderName, parent: parentID, type: .folder))
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                let audioInfo = AudioMetaData(duration: duration, recordingURLFileName: recordingURLFileName)
                let file = Item(name: fileName, parent: parentID, date: date, type: .recording, audioInfo: audioInfo)
                self?.items.append(file)
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
                return self.removeItem(itemID: folderID)
            }
        .eraseToAnyPublisher()
    }
    
    func removeItem(itemID: UUID) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                items.removeAll(where: {$0.id == itemID})
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError> {
        Future<Void, DatabaseError> { promise in
            self.queue.async { [weak self] in
                guard let self else { return }
                items.removeAll(where: {ids.contains($0.id)})
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
