//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine

enum SortType: CaseIterable {
    case dateAsc, dateDesc, name
    
    func toString() -> String {
        switch(self){
        case .dateAsc:
            "Date ↑"
        case .dateDesc:
            "Date ↓"
        case .name:
            "Name  "
        }
    }
}

final class FolderListViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var sortType = SortType.dateAsc {
        didSet {
            let folders = items.filter({$0 is Folder})
            let files = items.filter({$0 is AudioRecording})
            self.items = self.sortItems(folders) + self.sortItems(files)
        }
    }
    @Published var playbackFile: AudioRecording?
    @Published var hasPlaybackFile = false
    
    @Published var popup = PopupInput()
    @Published var itemAction: ItemAction? = nil
    @Published var editingItem: Item? = nil
    @Published var moveViewIsPresented = false {
        willSet {
            if newValue == false {
                self.setAction(action: .none, item: nil)
            }
        }
    }
    
    let database: DataManager
    @Published var currentFolder: Folder?
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    var sortButtonTitle: String { sortType.toString() }
    
    // TODO: swap w/Realm
    // TODO: REMOVE - TEMP FILES/FOLDERS for development
    init(database: DataManager = MockDataManager(folders: MockDataManager.sampleFolders, files: MockDataManager.sampleFiles), queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
    }
    
    private func sortByName(_ items: [Item]) -> [Item]{
        return items.sorted(by: { a, b in
            a.name < b.name
        })
    }
    private func sortByDateAsc(_ items: [Item]) -> [Item]{
        return items.sorted(by: { a, b in
            a.date < b.date
        })
    }
    private func sortByDateDesc(_ items: [Item]) -> [Item]{
        return items.sorted(by: { a, b in
            a.date > b.date
        })
    }
    
    func sortItems(_ items: [Item]) -> [Item] {
        switch(self.sortType){
        case .dateAsc:
            return sortByDateAsc(items)
        case .dateDesc:
            return sortByDateDesc(items)
        case .name:
            return sortByName(items)
        }
    }
        
    func setAction(action: ItemAction, item: Item?) {
        editingItem = item
        itemAction = action
        
        if itemAction == .rename {
            self.popup = PopupInput(popupTitle: "Rename",
                                    prompt: "Enter folder name",
                                    placeholder: editingItem?.name ?? "")
            return
        }
        
        if itemAction == ItemAction.add {
            self.popup = PopupInput(popupTitle: "Add Folder",
                                    prompt: "Enter folder name",
                                    placeholder: "New Folder")
            return
        }
    }
    
    
    // MARK: main logic
    func setFolder(item: Item){
        guard item is Folder else { return }
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
                guard let self else { return }
                let sortedFolders = self.sortItems(folders)
                let sortedFiles = self.sortItems(files)
                self.items = sortedFolders + sortedFiles
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        self.loadItems(atFolderID: currentFolder?.id)
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadItems(atFolderID: currentFolder.parent)
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
    
    func moveItem(item: Item, destination: UUID?) {
        if item is Folder {
            database.moveFolder(folderID: item.id, newParentID: destination)
                .sink { _ in
                }
                .store(in: &cancellables)
            
        } else {
            database.moveFile(fileID: item.id, newParentID: destination)
                .sink { _ in
                }
                .store(in: &cancellables)
        }
    }
    
//    func addFile(fileName: String = "New File", duration: TimeInterval, fileURL: URL) {
//        database.addFile(fileName: fileName, date: Date(), parentID: self.currentFolder?.id,
//                         duration: duration, recordingURL: fileURL)
//            .sink { [weak self] in
//                self?.loadItems(atFolderID: self?.currentFolder?.id)
//            }
//            .store(in: &cancellables)
//    }
    
    func addFolder(folderName: String = "New Folder") {
        database.addFolder(folderName: folderName, parentID: currentFolder?.id)
            .sink { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            }
            .store(in: &cancellables)
    }
    
    func setPlaybackFile(item: Item) {
        if item is AudioRecording {
            self.playbackFile = (item as! AudioRecording)
            self.hasPlaybackFile = true
        }
    }
}
