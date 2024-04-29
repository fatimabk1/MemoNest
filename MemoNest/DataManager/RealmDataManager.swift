//
//  RealmDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import Combine
import RealmSwift

// TODO: cleanup functions that can be item instead of separate folder/file


final class RealmManager {
    static let shared = RealmManager()
//    let queue = DispatchQueue(label: "memonest.database", qos: .background)
    let queue = DispatchQueue.main
    var realm: Realm?
    
    private let configuration = Realm.Configuration (
        schemaVersion: 0,
        migrationBlock: { migration, oldSchema in
            // future migration code
        })
    
    private init() {
        Realm.Configuration.defaultConfiguration = configuration
//        print(queue)
//        queue.sync { [weak self] in
            do {
                realm = try Realm()
            } catch {
                print("Failed to initialize Realm: \(error)")
                realm = nil
            }
//        }
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
    private let changesPublisher = PassthroughSubject<Void, Never>()
    
    init() {
        setupDatabaseObserver()
    }
    
    private func setupDatabaseObserver() {
        RealmManager.shared.permformOperation { [weak self] realm in
            self?.token = realm.observe { _, _ in
                self?.changesPublisher.send()
            }
        }
    }
    
    // notifies when database has changed
    func databaseChangesPublisher() -> AnyPublisher<Void, Never> {
        changesPublisher
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError> {
        return Future<Item?, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let folder = realm.object(ofType: ItemDB.self, forPrimaryKey: folderID)
                promise(.success(folder?.asItem()))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError> {
        return Future<[Item], DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                
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
        return Future<[Item], DatabaseError> { promise in
            RealmManager.shared.permformOperation {  realm in
                let items = realm.objects(ItemDB.self)
                let folderGroup = items.where { $0.typeRaw == "folder" && $0.parent == parentID }
                let folders = folderGroup.map({$0.asItem()})
                promise(.success(Array(folders)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
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
                return self.removeAll(ids: files.map({$0.id}))
            }
        // delete folder itself
            .flatMap { [weak self] _  -> AnyPublisher<Void, DatabaseError> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.removeSingleFolder(folderID: folderID)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation {  realm in
                let folder = realm.object(ofType: ItemDB.self, forPrimaryKey: folderID)
                guard let folder else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        realm.delete(folder)
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
    
    func removeFile(fileID: UUID) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let file = realm.object(ofType: ItemDB.self, forPrimaryKey: fileID)
                guard let file else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        realm.delete(file)
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
    
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let items = realm.objects(ItemDB.self)
                let itemsToRemove = items.filter { item in
                    ids.contains(item.id)
                }
                
                do {
                    try realm.write {
                        realm.delete(itemsToRemove)
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
    
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let folderDB = realm.object(ofType: ItemDB.self, forPrimaryKey: folderID)
                guard let folderDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        folderDB.name = name
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
    
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation {realm in
                let fileDB = realm.object(ofType: ItemDB.self, forPrimaryKey: fileID)
                guard let fileDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        fileDB.name = name
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
    
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let folderDB = realm.object(ofType: ItemDB.self, forPrimaryKey: folderID)
                guard let folderDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        folderDB.parent = newParentID
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
    
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError> {
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
                let fileDB = realm.object(ofType: ItemDB.self, forPrimaryKey: fileID)
                guard let fileDB else { return promise(.failure(.itemNotFound)) }
                
                do {
                    try realm.write {
                        fileDB.parent = newParentID
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
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
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
        return Future<Void, DatabaseError> { promise in
            RealmManager.shared.permformOperation { realm in
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
