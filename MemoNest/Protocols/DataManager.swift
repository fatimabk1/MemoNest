//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import Combine

protocol DataManager {   
    var files: [File] { get }
    var folders: [Folder] { get }
    var cancellables: Set<AnyCancellable> { get}
    
    // fetch
    func fetchFiles(parentID: UUID?) -> AnyPublisher<[File], Never>
    func fetchFolders(parentID: UUID?) -> AnyPublisher<[Folder], Never>
    
    // remove
    func removeFolder(folderID: UUID) -> AnyPublisher<Void, Never>
    func removeSingleFolder(folderID: UUID) -> AnyPublisher<Void, Never> 
    func removeFile(fileID: UUID) -> AnyPublisher<Void, Never>
    func removeAll(ids: [UUID]) -> AnyPublisher<Void, Never> 
//    func removeFolder(folderID: UUID, completion: @escaping () -> Void)
//    func listContentRecursive(folderID: UUID, completion: @escaping ([UUID]) -> Void)
//    func removeFile(fileID: UUID, completion: @escaping () -> Void)
//    func removeAll(ids: [UUID], completion: @escaping () -> Void)
    
    // rename
    func renameFolder(folderID: UUID, name: String) -> AnyPublisher<Void, Never>
    func renameFile(fileID: UUID, name: String) -> AnyPublisher<Void, Never>
    
    // move
    func moveFolder(folderID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never>
    func moveFile(fileID: UUID, newParentID: UUID?) -> AnyPublisher<Void, Never>
    
    // add
    func addFolder(folderName: String, parentID: UUID?) -> AnyPublisher<Void, Never>
    func addFile(fileName: String, parentID: UUID?) -> AnyPublisher<Void, Never>
}
