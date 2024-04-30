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
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, DatabaseError>
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError>
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], DatabaseError>
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, DatabaseError> // for nested folder
    func removeItem(itemID: UUID) -> AnyPublisher<Void, DatabaseError>
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, DatabaseError>
    func renameItem(itemID: UUID, name: String) -> AnyPublisher<Void, DatabaseError>
    func moveItem(itemID: UUID, newParentID: UUID?) -> AnyPublisher<Void, DatabaseError>
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, DatabaseError>
    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, DatabaseError>
}
