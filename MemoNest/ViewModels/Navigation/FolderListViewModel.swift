//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine

struct RecordingData {
    var recordingDate: Date = Date()
    var recordingParent: UUID? = nil
    var recordingDuration: TimeInterval = 0
    var recordingURLFileName: String?
}

final class FolderListViewModel: ObservableObject {
    // MARK: - Folder List Data
    @Published var items = [Item]()
    @Published var currentFolder: Item?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var error: TitledError?
    
    @Published var sortType = SortType.dateAsc {
        didSet {
            let folders = items.filter({$0.isFolder()})
            let files = items.filter({$0.isAudio()})
            self.items = self.sortItems(folders) + self.sortItems(files)
        }
    }
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
    
    var currentFolderTitle: String { currentFolder?.name ?? "Library" }
    var hasParent: Bool { currentFolder != nil }
    
    // MARK: - Recording Data
    private let recordingService = RecordingService()
    
    // Data used for addFile()
    @Published var recordingData: RecordingData? = nil
    @Published var recordingName: String = "New Recording"
    
    // Data used for recording display
    @Published var isRecording = false
    @Published var recordingParentTitle: String = "Library"
    @Published var currentDuration: TimeInterval = 0 // TODO: CHECK IF THIS CAN BE PRIVATE, UNPUBLISHED
    var formattedcurrentDuration: String { FormatterService.formatTimeInterval(seconds: currentDuration) }
    private var timerSubscription: AnyCancellable?
    var formattedDuration: String {
        FormatterService.formatTimeInterval(seconds: recordingData?.recordingDuration ?? 0)
    }
    

    // MARK: - shared data
    let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    init(database: DataManager, queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
        subscribeToRecordingEvents()
//        loadOnDatabaseChange()
    }
    
    private func subscribeToRecordingEvents() {
        recordingService.status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .recording:
                    print("status: recording")
                    self?.isRecording = true
                    self?.recordingData = RecordingData(recordingParent: self?.currentFolder?.id)
                    self?.recordingParentTitle = self?.currentFolderTitle ?? "Library"
                    self?.timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                        .autoconnect()
                        .sink { [weak self] date in
                            if let startTime = self?.recordingData?.recordingDate {
                                self?.currentDuration = startTime.distance(to: date)
                            }
                        }
                case .finished(let duration, let urlFileName):
                    print("status finished")
                    self?.isRecording = false
                    self?.timerSubscription?.cancel()
                    self?.timerSubscription = nil
                    self?.recordingData?.recordingURLFileName = urlFileName
                    self?.recordingData?.recordingDuration = duration
                    self?.addFile()
                    self?.recordingData = nil
                    self?.recordingName = "New Recording"
                    self?.currentDuration = 0
                case .idle:
                    print("status idle")
                    
                case .error(let err):
                    self?.hasError = true
                    self?.error = err
                }
            }
            .store(in: &cancellables)
    }
    
    func updateParentFolder(parentID: UUID?, folderTitle: String) {
        recordingData?.recordingParent = parentID
        recordingParentTitle = folderTitle
    }
    
    func handleRecordButtonPress() {
        if isRecording {
            recordingService.stopRecording()
        } else {
            recordingService.startRecording(parentID: currentFolder?.id, folderTitle: currentFolderTitle)
        }
    }
        
    private func addFile() {
        if hasError { return }
        guard let recordingData else {
            hasError = true
            error = RecordingError.incompleteData
            return
        }
        
        if let URLFileName = recordingData.recordingURLFileName {
            database.addFile(fileName: recordingName, date: recordingData.recordingDate,
                             parentID: recordingData.recordingParent, duration: recordingData.recordingDuration, recordingURLFileName: URLFileName)
            .sink (
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        self.hasError = true
                        self.error = error
                    }
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                }
            )
            .store(in: &cancellables)
        }
    }

    private func handleError(completionStatus: Subscribers.Completion<DatabaseError>) {
        if case let .failure(error) = completionStatus {
            self.hasError = true
            self.error = error
            print("Received error: \(error)")
        }
    }
    
    private func sortItems(_ items: [Item]) -> [Item] {
        switch sortType {
        case .dateAsc:
            return items.sortedByDateAsc()
        case .dateDesc:
            return items.sortedByDateDesc()
        case .name:
            return items.sortedByName()
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
                                    prompt: "New Folder",
                                    placeholder: "")
            return
        }
    }
    
    func handleMenuTap(item: Item, action: ItemAction) {
        if action == .delete {
            removeItem(item: item)
        } else if action == .rename {
            setAction(action: action, item: item)
        } else if action == .move {
            setAction(action: action, item: item)
            moveViewIsPresented = true
        }
    }
    
    // MARK: - main logic
    // TODO: -- LESS GENERIC Name (UPDATE, change)
    func setFolder(item: Item){
        guard item.type == .folder else { return }
        loadItems(atFolderID: item.id)
    }
    
//    func loadOnDatabaseChange() {
//        database.databaseChangesPublisher()
//            .sink { [weak self] folder in
//                print("received change")
//                self?.loadItems(atFolderID: self?.currentFolder?.id)
//            }
//            .store(in: &cancellables)
//    }
    
    func loadItems(atFolderID folderID: UUID?) {
        if let folderID {
            database.fetchFolderInfo(folderID: folderID)
                .receive(on: queue)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] folder in
                    self?.currentFolder = folder
                })
                .store(in: &cancellables)
        } else {
            self.currentFolder = nil
        }
        
        database.fetchFolders(parentID: folderID)
            .zip(database.fetchFiles(parentID: folderID))
            .receive(on: queue)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] folders, files in
                guard let self else { return }
                let sortedFolders = self.sortItems(folders)
                let sortedFiles = self.sortItems(files)
                self.items = sortedFolders + sortedFiles
                print("finished loading items\nAPP STATE - READY")
                isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        isLoading = true
        self.loadItems(atFolderID: currentFolder?.id)
    }
    
    func goBack() {
        guard let currentFolder else { return }
        loadItems(atFolderID: currentFolder.parent)
    }
    
    //FIXME: REMOVE if branch after cleaning up DB
    func renameItem(item: Item, name: String) {
        if item.isFolder() {
            database.renameFolder(folderID: item.id, name: name)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        } else {
            database.renameFile(fileID: item.id, name: name)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }
    
    func removeItem(item: Item) {
        if item.isFolder() {
            database.removeFolder(folderID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    print("completion: \(completion)")
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        } else {
            // TODO: stop playback if playing, then remove
            database.removeFile(fileID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }
    
    func moveItem(item: Item, destination: UUID?) {
        if item.isFolder() {
            database.moveFolder(folderID: item.id, newParentID: destination)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
            
        } else {
            database.moveFile(fileID: item.id, newParentID: destination)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
    }

    // TODO: figure out why first add & first delete are not loading in UI
    // LoadItems is called, but fetchFolders retunrs 0 items
    func addFolder(folderName: String = "New Folder") {
        print("Adding new folder")
        let name = folderName == "" ? "New Folder" : folderName
        database.addFolder(folderName: name, parentID: currentFolder?.id)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            })
            .store(in: &cancellables)
    }
}
