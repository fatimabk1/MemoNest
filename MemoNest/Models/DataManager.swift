//
//  DataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

// conforms to protocol, concrete implementation
// TODO: write protocol w/functions, vars
// TODO: add Realm implementation with real data
final class DataManager {
    private var files: [File] // TODO, SHOULD BE DB
    private var folders: [Folder]
    
    static let shared = DataManager()
    private init() {
        let folderA = Folder(name: "A")
        let folderB = Folder(name: "B")
        let folderC = Folder(name: "C")
        self.folders = [folderA, folderB, folderC]
        
        let file1 = File(name: "1")
        let file2 = File(name: "2")
        let file3 = File(name: "3")
        self.files = [file1, file2, file3]
    }
    
    // MARK: folder functions
    func fetchFolders(completion: @escaping ([Folder]) -> Void) {
       completion(folders)
    }
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) {
        // DISPATCH QUEUE / async in all completions here
        DispatchQueue.global().async { [weak self] in
            self?.folders.append(Folder(name: folderName, parent: parent))
            completion()
        }
    }
    func removeFolder(folderId: UUID) {
        
    }
    func moveFolder() {}
    func renameFolder(){}
    
    // MARK: file functions
    func fetchFiles(completion: @escaping ([File]) -> Void ) {
        completion(files)
    }
    func addFile(fileName: String, parent: UUID?, completion: @escaping () -> Void) {}
    func removeFile() {}
    func moveFile() {}
    func renameFile(){}
    
}
