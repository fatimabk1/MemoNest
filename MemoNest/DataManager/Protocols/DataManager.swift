//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import Combine

enum DatabaseError: TitledError {
    case failedDelete, itemNotFound, failedAdd, realmNotInstantiated
    
    var title: String {
        switch(self){
            
        case .failedDelete:
            "Unable to delete. Please try again."
        case .itemNotFound:
            "Item not found. Please try again."
        case .failedAdd:
            "Unable to add item. Please try again."
        case .realmNotInstantiated:
            "Database not instantitated. Please reinstall app."
        }
    }
}

protocol DataManager {    
//    func databaseChangesPublisher() -> AnyPublisher<Void, Never>
    
    // fetch
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError>
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError>
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError>
    
    // remove
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError>
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError>
    func removeFile(fileID: UUID) -> AnyPublisher<Void, DatabaseError>
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError>
    
    // rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, DatabaseError>
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, DatabaseError>
    
    // move
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError>
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError>
    
    // add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, DatabaseError>
    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, DatabaseError>
}
