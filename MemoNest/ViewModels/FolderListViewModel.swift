//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine


final class FolderListViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var playbackFile: File?
    @Published var hasPlaybackFile = false
    
    private var currentFolder: Folder?
    private let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()

    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    // TODO: swap w/Realm
    init(database: DataManager = MockDataManager(), queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
    }
    
    func setFolder(item: Item){
        guard item is Folder else { return }
        print("setting current Folder: \(item.name) [\(String(describing: item.id))]")
        loadItems(atFolderID: item.id)
    }
    
    func loadItems(atFolderID folderID: UUID?) {
        database.fetchFolderInfo(folderID: folderID)
            .receive(on: queue)
            .sink { [weak self] folder in
                guard let self else { return }
                self.currentFolder = folder
            }
            .store(in: &cancellables)
        
        database.fetchFolders(parentID: folderID)
            .zip(database.fetchFiles(parentID: folderID))
            .receive(on: queue)
            .sink { [weak self] folders, files in
                self?.items = folders + files
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        self.loadItems(atFolderID: currentFolder?.id)
    }
    
    func renameItem(item: Item, name: String) {
        if item is Folder {
            database.renameFolder(folderID: item.id, name: name)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        } else {
            database.renameFile(fileID: item.id, name: name)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        }
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadItems(atFolderID: currentFolder.parent)
    }
    
    func sort1() {}
    
    func sort2() {}
    
    func removeItem(item: Item) {
        if item is Folder {
            database.removeFolder(folderID: item.id)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        } else {
            database.removeFile(fileID: item.id)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        }
    }
    
    func moveItem(item: Item, destinationFolderID folderID: UUID) {
        if item is Folder {
            database.moveFolder(folderID: item.id, newParentID: folderID) 
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        
        } else {
            database.moveFile(fileID: item.id, newParentID: folderID)
                .sink { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
                .store(in: &cancellables)
        }
    }
    
    func addFile(fileName: String = "New File") {
        database.addFile(fileName: fileName, parentID: self.currentFolder?.id)
            .sink { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            }
            .store(in: &cancellables)
    }
    
    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parentID: currentFolder?.id)
            .sink { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            }
            .store(in: &cancellables)
    }
    
    func setPlaybackFile(item: Item) {
        if item is File {
            self.playbackFile = (item as! File)
            self.hasPlaybackFile = true
        }
    }

}
