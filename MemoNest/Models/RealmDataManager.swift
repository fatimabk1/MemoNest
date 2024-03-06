//
//  RealmDataManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

final class RealmDataManager: DataManager {
    private var files: [File]
    private var folders: [Folder]
 
    init() {
        let folderA = Folder(name: "Folder A")
        let folderB = Folder(name: "Folder B")
        let folderC = Folder(name: "Folder C")
        let folderAA1 = Folder(name: "Folder AA1", parent: folderA.id)
        let folderAA2 = Folder(name: "Folder AA2", parent: folderA.id)
        let folderAAA1 = Folder(name: "Folder AAA1", parent: folderAA1.id)
        self.folders = [folderA, folderB, folderC, folderAA1, folderAA2, folderAAA1]
        let file1 = File(name: "File1 in Library")
        let file2 = File(name: "File2 in Library")
        let file3 = File(name: "File3 in Library")
        let fileA1 = File(name: "File in Folder A", folder: folderA.id)
        let fileAA1 = File(name: "File in Folder AA1", folder: folderAA1.id)
        let fileAA2 = File(name: "File in Folder AA2", folder: folderAA2.id)
        let fileAAA1 = File(name: "File in Folder AAA1", folder: folderAAA1.id)
        self.files = [file1, file2, file3, fileA1, fileAA1, fileAA2, fileAAA1]
    }
    
    internal func removeSingleFolder(folderID: UUID, completion: @escaping () -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
        self?.folders.removeAll(where: {$0.id == folderID})
        completion()
    }
}
    
    // MARK: folder functions
    func fetchFolders(parentID: UUID?, completion: @escaping ([Folder]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
            completion((self?.folders ?? []).filter({$0.parent == parentID}))
        }
    }
    func addFolder(folderName: String, parent: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            self?.folders.append(Folder(name: folderName, parent: parent))
            completion()
        }
    }
    
    /*
     - option 1: recursive. make sure to wait for async to complete before continuing to next node/item
     - option 2: function gives folders in leaf --> root order.
         Iterate over folders and delete all content async
         Then delete folder for that item
         Once complete, all functions for deletion have been dispatched.
     - ** option 3: list all folder ids. delete folders and files, making sure to watch what can happen at the same time vs what we need to wait for (for each vs while)
     
     - A
        - A1
            -f1
        - A2
            -f2
            - AA2
                -f3
        - f4
     
     [AA2, A2, A1, A]
     
     */
    func removeFolder(folderID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            var removalList = [UUID]()
            var nestedFolders = [UUID]()
            removalList.append(folderID)
            nestedFolders.append(folderID)
                        
            // BFS compile list of all nested folders under folder to delete
            // NOTE: over-called while because fetchFolders is not being waited for / nestedFolders has delay in updating. - while loop blocks artificially until it finishes. bad performance
            //A for loop would be better because it is called for each item.
            //Don't need to wait bc processing does not rely on updates to the list we are iterating on
            while !nestedFolders.isEmpty {
                let folderID = nestedFolders.removeFirst()
                self.fetchFolders(parentID: folderID) { folders in
                    for folder in folders {
                        removalList.append(folder.id)
                        nestedFolders.append(folder.id)
                    }
                }
            }
            
            //NOTE: everything below executes before fetchFolders returns bc we didn't properly wait for
            // async function to return. Waiting means nested inside closure.
            printRemovalList(folderIDs: removalList)
            
            // delete files within each folder to be deleted
            for folderID in removalList {
                self.fetchFiles(parentID: folderID) { files in
                    for file in files {
                        self.removeFile(fileID: file.id) {}
                        self.printLibraryContents()
                    }
                }
            }
            
            // delete folders
            for folderID in removalList {
                self.removeSingleFolder(folderID: folderID) {}
                self.printLibraryContents()
            }
            self.printLibraryContents()
            completion()
        }
    }
    
    
    private func printLibraryContents() {
        print("\nLIBRARY:")
        for folder in folders {
            print(folder.name)
        }
        for file in files {
            print(file.name)
        }
    }
    
    private func printRemovalList(folderIDs: [UUID]) {
        print("\nRemoval list:")
        for f in folderIDs {
            print(self.folders.filter({$0.id == f}).first?.name ?? "NO match")
        }
    }
    
    func moveFolder(folderID: UUID, newParentID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.folders.firstIndex(where: {$0.id == folderID})
            guard let index else { return }
            
            var folder = self.folders[index]
            folder.parent = newParentID
            self.folders[index] = folder
            completion()
        }
    }
    func renameFolder(folderID: UUID, name: String, completion: @escaping () -> Void){
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.folders.firstIndex(where: {$0.id == folderID})
            guard let index else { return }
            
            var folder = self.folders[index]
            folder.name = name
            self.folders[index] = folder
            completion()
        }
    }
    func fetchSingleFolder(folderID: UUID?, completion: @escaping (Folder?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let folderID {
                let parentFolder = folders.first(where: {$0.id == folderID})
                completion(parentFolder)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: file functions
    func fetchFiles(parentID: UUID?, completion: @escaping ([File]) -> Void ) {
        completion(files.filter({$0.folder == parentID}))
    }
    func addFile(fileName: String, folderID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            let file = File(name: fileName, folder: folderID)
            self?.files.append(file)
            completion()
        }
    }
    func removeFile(fileID: UUID, completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            files.removeAll(where: {$0.id == fileID})
            completion()
        }
    }
    func moveFile(fileID: UUID, newFolderID: UUID?, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.files.firstIndex(where: {$0.id == fileID})
            guard let index else { return }
            
            var file = self.files[index]
            file.folder = newFolderID
            self.files[index] = file
            completion()
        }
    }
    func renameFile(fileID: UUID, name: String, completion: @escaping () -> Void){
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            let index = self.files.firstIndex(where: {$0.id == fileID})
            guard let index else { return }
            
            var file = self.files[index]
            file.name = name
            self.files[index] = file
            completion()
        }
    }
    
}
