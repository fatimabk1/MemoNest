//
//  RealmDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import Combine
import RealmSwift


final class RealmManager {
    let queue = DispatchQueue(label: "serial-queue")
    var realm: Realm?
    private let configuration = Realm.Configuration (
        schemaVersion: 0,
        migrationBlock: { migration, oldSchema in
            // Future migration code
        })
    
    init(queue: DispatchQueue = DispatchQueue(label: "memonest.database", qos: .background)) {
        Realm.Configuration.defaultConfiguration = configuration
        queue.async { [weak self] in
            do {
                self?.realm = try Realm()
            } catch {
                print("Failed to initialize Realm: \(error)")
                self?.realm = nil
            }
        }
    }
    
    func permformOperation(_ operation: @escaping (Realm) -> Void) {
        queue.async { [weak self] in
            guard let realm = self?.realm else {
                print("Realm is not initialized.")
                return
            }
            operation(realm)
        }
    }
}


final class RealmDataManager: DataManager {
    private var cancellables = Set<AnyCancellable>()
    private var token: NotificationToken?
    private let queue = DispatchQueue(label: "serial-queue")
    private var realm: Realm?
    
    init() {
        queue.async { [weak self] in
            do {
                let configuration = Realm.Configuration (
                    schemaVersion: 0,
                    migrationBlock: { migration, oldSchema in
                        // return Future migration code
                })
                self?.realm = try Realm(configuration: configuration, queue: self?.queue)
            } catch {
                print("Failed to initialize Realm: \(error)")
                self?.realm = nil
            }
        }
    }
    
    private func permformOperation(_ operation: @escaping (Realm) -> Void) {
        queue.async { [weak self] in
            guard let realm = self?.realm else {
                print("Realm is not initialized.")
                return
            }
            operation(realm)
        }
    }

    
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError> {
        return Future<Item?, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let folder = realm.object(ofType: ItemDB.self, forPrimaryKey: folderID)
                promise(.success(folder?.asItem()))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        return Future<[Item], DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let items = realm.objects(ItemDB.self)
                let fileGroup = items.where { $0.typeRaw == "recording" && $0.parent == parentID }
                let files = fileGroup.map({$0.asItem()})
                promise(.success(Array(files)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        return Future<[Item], DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let items = realm.objects(ItemDB.self)
                let folderGroup = items.where { $0.typeRaw == "folder" && $0.parent == parentID }
                let folders = folderGroup.map({$0.asItem()})
                promise(.success(Array(folders)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    // TODO: REALM BFS SYNC DELETIONs
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError> {
        self.fetchFolders(parentID: folderID)
        // handle child folders
            .flatMap { [weak self] childFolders -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                let childFolderDeletions = childFolders.compactMap { self.removeFolder(folderID: $0.id) } // recursive delete each child folder
                return Publishers.MergeMany(childFolderDeletions) // merge into a single event stream
                    .collect() // wait for all sync deletions to finish
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
                let fileDeletions = files.compactMap({ self.removeItem(itemID: $0.id)})
                return Publishers.MergeMany(fileDeletions) // merge into a single event stream
                    .collect() // wait for all sync deletions to finish
                    .map { _ in () } // transform output to void to match AnyPublisher type
                    .eraseToAnyPublisher()
            }
        // delete folder itself
            .flatMap { [weak self] _  -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeItem(itemID: folderID)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func removeItem(itemID: UUID) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let item = realm.object(ofType: ItemDB.self, forPrimaryKey: itemID)
                guard let item else { return promise(.failure(.itemNotFound)) }

                do {
                    if let fileName = item.recordingURLFileName {
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
                        try FileManager.default.removeItem(at: url)
                    }
                    
                    try realm.write {
                        realm.delete(item)
                        promise(.success(()))
                    }
                   
                } catch let err {
                    print("error: \(err)")
                    promise(.failure((.failedDelete)))
                }
                
                
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
//    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError> {
//        return Future<Void, DatabaseError> { [weak self] promise in
//            self?.permformOperation { realm in
//                let items = realm.objects(ItemDB.self)
//                let itemsToRemove = items.filter { item in
//                    ids.contains(item.id)
//                }
//                
//                
//                do {
//                    try realm.write {
//                        realm.delete(itemsToRemove)
//                        promise(.success(()))
//                    }
//                } catch {
//                    promise(.failure((.failedDelete)))
//                }
//            }
//        }
//        .receive(on: RunLoop.main)
//        .eraseToAnyPublisher()
//    }
    
    func renameItem(itemID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let itemDB = realm.object(ofType: ItemDB.self, forPrimaryKey: itemID)
                guard let itemDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        itemDB.name = name
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure((.failedDelete)))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    
    func moveItem(itemID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let itemDB = realm.object(ofType: ItemDB.self, forPrimaryKey: itemID)
                guard let itemDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        itemDB.parent = newParentID
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure((.failedDelete)))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                do {
                    try realm.write {
                        let folderDB = ItemDB(name: folderName, parent: parentID, typeRaw: ItemType.folder.rawValue)
                        realm.add(folderDB)
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure((.failedAdd)))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { [weak self] promise in
            self?.permformOperation { realm in
                let fileDB = ItemDB(name: fileName, parent: parentID, date: date, typeRaw: ItemType.recording.rawValue, duration: duration, recordingURLFileName: recordingURLFileName)
                
                do {
                    try realm.write {
                        realm.add(fileDB)
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure((.failedAdd)))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
