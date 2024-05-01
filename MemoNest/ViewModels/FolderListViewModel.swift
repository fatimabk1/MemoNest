//
//  FolderListViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import Combine
import AVFoundation


final class FolderListViewModel: ObservableObject {
    // MARK: - shared data
    let database: DataManager
    private let queue: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
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
    @Published var recordingData: RecordingData? = nil
    @Published var recordingName: String = "New Recording"
    @Published var isRecording = false
    @Published var recordingParentTitle: String = "Library"
    @Published var currentRecordingDuration: TimeInterval = 0
    
    private let recordingService = RecordingService()
    private var recordingTimerSubscription: AnyCancellable?
    
    var formattedcurrentDuration: String {
        FormatterService.formatTimeInterval(seconds: currentRecordingDuration)
    }
    
    // MARK: - Playback Data
    @Published var isPlaying = false
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var playbackDuration: TimeInterval = 0
    @Published var playbackItemID:  UUID? = nil
    
    private let playbackService = PlaybackService()
    private var playbackTimerSubscription: AnyCancellable?
    
    var playbackFormattedDuration: String {
        FormatterService.formatTimeInterval(seconds: playbackDuration)
    }
    
    
    init(database: DataManager, queue: DispatchQueue = .main) {
        self.database = database
        self.queue = queue
        subscribeToRecordingEvents()
        subscribeToPlaybackEvents()
        setupAudioSession()
    }
   
    
    private func setupAudioSession() {
        print("calling setupAudioSession()")
        let audioSession = AVAudioSession()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            
        }
    }
    
    // MARK: - Playback Functions
    private func subscribeToPlaybackEvents() {
        playbackService.status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .ready(let duration):
                    self?.playbackDuration = duration
                case .playing(let currentTime):
                    self?.isPlaying = true
                    self?.currentPlaybackTime = currentTime
                    // keep current time synced with audio play time
                    self?.playbackTimerSubscription = Timer.publish(every: 0.01, on: .main, in: .common)
                        .autoconnect()
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] time in
                            if let current = self?.currentPlaybackTime, let duration = self?.playbackDuration,
                                current >= duration {
                                self?.playbackTimerSubscription?.cancel()
                                self?.isPlaying = false
                                return
                            }
                            
                            self?.currentPlaybackTime += 0.01
                        }
                case .paused:
                    self?.isPlaying = false
                    self?.playbackTimerSubscription?.cancel()
                case .seek(let targetTime):
                    self?.currentPlaybackTime = targetTime
                case .idle:
                    print("idle")
                case .error(let err):
                    self?.hasError = true
                    self?.error = err
                }
            }
            .store(in: &cancellables)
    }
    
    func setRecording(item: Item) {
        if item.id != playbackItemID {
            playbackService.setupPlayback(item: item)
            playbackItemID = item.id
        }
    }
    
    func playRecording() { playbackService.play() }
    
    func pauseRecording() { playbackService.pause() }
    
    func seek(to time: TimeInterval) { playbackService.seek(to: time) }
    
    func seekForward() { playbackService.seekForward() }
    
    func seekBackward() { playbackService.seekBackward() }
    

    
    // MARK: - Recording Functions
    private func subscribeToRecordingEvents() {
        recordingService.status
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .recording:
                    self?.isRecording = true
                    self?.recordingData = RecordingData(recordingParent: self?.currentFolder?.id)
                    self?.recordingParentTitle = self?.currentFolderTitle ?? "Library"
                    self?.recordingTimerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                        .autoconnect()
                        .sink { [weak self] date in
                            if let startTime = self?.recordingData?.recordingDate {
                                self?.currentRecordingDuration = startTime.distance(to: date)
                            }
                        }
                case .finished(let duration, let urlFileName):
                    self?.isRecording = false
                    self?.recordingTimerSubscription?.cancel()
                    self?.recordingTimerSubscription = nil
                    self?.recordingData?.recordingURLFileName = urlFileName
                    self?.recordingData?.recordingDuration = duration
                    self?.addFile()
                    self?.recordingData = nil
                    self?.recordingName = "New Recording"
                    self?.currentRecordingDuration = 0
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
    
    // MARK: - Folder List Functions
    func changeFolder(item: Item){
        guard item.type == .folder else { return }
        loadItems(atFolderID: item.id)
    }
    
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
    
    func renameItem(item: Item, name: String) {
        database.renameItem(itemID: item.id, name: name)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            })
            .store(in: &cancellables)
    }
    
    func removeItem(item: Item) {
        if item.isAudio(), item.id == playbackItemID {
            playbackService.cancelPlayback(recordingID: item.id)
            playbackItemID = nil
        }
        if item.isAudio() {
            database.removeItem(itemID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        } else {
            database.removeFolder(folderID: item.id)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.handleError(completionStatus: completion)
                }, receiveValue: { [weak self] in
                    self?.loadItems(atFolderID: self?.currentFolder?.id)
                })
                .store(in: &cancellables)
        }
       
    }
    
    func moveItem(item: Item, destination: UUID?) {
        database.moveItem(itemID: item.id, newParentID: destination)
            .sink(receiveCompletion: { [weak self] completion in
                self?.handleError(completionStatus: completion)
            }, receiveValue: { [weak self] in
                self?.loadItems(atFolderID: self?.currentFolder?.id)
            })
            .store(in: &cancellables)
    }

    func addFolder(folderName: String = "New Folder") {
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
