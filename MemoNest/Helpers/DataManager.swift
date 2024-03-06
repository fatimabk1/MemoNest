//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

protocol DataManager {    
    // folder functions
    func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void);
    func fetchFolders(parentID: UUID?, completion: @escaping ([Folder]) -> Void);
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) ;
    func removeFolder(folderID: UUID, completion: @escaping () -> Void);
    func moveFolder(folderID: UUID, newParentID: UUID?, completion: @escaping () -> Void);
    func renameFolder(folderID: UUID, name: String, completion: @escaping () -> Void);
    func fetchSingleFolder(folderID: UUID?, completion: @escaping (Folder?) -> Void);
    
    // file functions
    func fetchFiles(parentID: UUID?, completion: @escaping ([File]) -> Void );
    func addFile(fileName: String, folderID: UUID?, completion: @escaping () -> Void);
    func removeFile(fileID: UUID, completion: @escaping () -> Void);
    func moveFile(fileID: UUID, newFolderID: UUID?, completion: @escaping () -> Void);
    func renameFile(fileID: UUID, name: String, completion: @escaping () -> Void);
}
