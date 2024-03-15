//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

protocol DataManager {   
    var files: [File] { get }
    var folders: [Folder] { get }
    
    // fetch
    func fetchFolders(parentID: UUID?, completion: @escaping ([Folder]) -> Void)
    func fetchFiles(parentID: UUID?, completion: @escaping ([File]) -> Void )
    
    // remove
    func removeFolder(folderID: UUID, completion: @escaping () -> Void)
    func listContentRecursive(folderID: UUID, completion: @escaping ([UUID]) -> Void)
    func removeFile(fileID: UUID, completion: @escaping () -> Void)
    func removeAll(ids: [UUID], completion: @escaping () -> Void)
    
    // rename
    func renameFolder(folderID: UUID, name: String, completion: @escaping () -> Void)
    func renameFile(fileID: UUID, name: String, completion: @escaping () -> Void)
    
    // move
    func moveFolder(folderID: UUID, newParentID: UUID?, completion: @escaping () -> Void)
    func moveFile(fileID: UUID, newFolderID: UUID?, completion: @escaping () -> Void)
    
    // add
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void)
    func addFile(fileName: String, folderID: UUID?, completion: @escaping () -> Void)
    
    
//    func fetchSingleFolder(folderID: UUID?, completion: @escaping (Folder?) -> Void)
//    
//    
//    // file functions
//    // folder functions
//    func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void)
//   
    
//    func removeFolder(folderID: UUID, completion: @escaping () -> Void)
   
}
