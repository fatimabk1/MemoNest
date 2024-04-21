//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import Combine

protocol DataManager {   
    var cancellables: Set<AnyCancellable> { get}
    
    // fetch
    func fetchFolderInfo(folderID: UUID?) -> AnyPublisher<Item?, Never>
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[Item], Never>
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Item], Never>
    
    // remove
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, Never>
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, Never> 
    func removeFile(fileID: UUID) -> AnyPublisher<Void, Never>
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, Never> 
    
    // rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, Never>
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, Never>
    
    // move
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never>
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never>
    
    // add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, Never>
    func addFile(fileName: String, date: Date, parentID: UUID?, duration: TimeInterval, recordingURLFileName: String) -> AnyPublisher<Void, Never>
}
