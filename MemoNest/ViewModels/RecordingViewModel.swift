//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine


final class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var hasError = false
    @Published var error: TitledError?
    @Published var filePath: URL?
    
    var recordingManager: RecordingManager
    var hasRecordPermission = false
    let database: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // Variables to hold audio recording data before creation
    @Published var recordingName: String = "New Recording \(Date())"
    @Published var recordingParentTitle: String = "Library"
    private var recordingDuration: TimeInterval = 0
    var recordingDate: Date = Date()
    var recordingParent: UUID? = nil
    var recordingURLFileName: String!
    let onFileAdded = PassthroughSubject<Void,Never>()
    var formattedDuration: String { FormatterService.formatTimeInterval(seconds: recordingDuration) }
    
    // duration of recording while in progress
    private var timerSubscription: AnyCancellable?
    @Published var currentDuration: TimeInterval = 0
    var formattedcurrentDuration: String { FormatterService.formatTimeInterval(seconds: currentDuration) }
    
    
    init(database: DataManager) {
        self.database = database
        self.recordingManager = RecordingManager()
        self.handleInterruptions()
    }
    
    private func handleInterruptions() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { notification in
                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                    let type = AVAudioSession.InterruptionType(rawValue: typeValue) else 
                {
                    print("\tno interrtuption type - returning")
                    return
                }
                
                switch type{
                case .began:
                    print("BEGAN recording interruption")
                    if self.isRecording {
                        print("stopping recording - calling stopRecording()")
                        self.stopRecording()
                    }
                default:
                    print("playback DEFAULT - no interruption")
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkPermissions() {
        recordingManager.requestPermission { [weak self] granted in
            guard let self else { return }
            self.hasRecordPermission = granted
        }
    }
    
    func updateParentFolder(parentID: UUID?, folderTitle: String) {
        print("updating parent folder to \(folderTitle)")
        recordingParent = parentID
        recordingParentTitle = folderTitle
    }
    
    func startRecording(parentID: UUID?, folderTitle: String) {
        checkPermissions()
        if !hasRecordPermission {
            hasError = true
            error = RecordingError.noPermission
            return
        }
    
        let result = recordingManager.setupRecorder()
        switch(result){
        case .success(let fileName):
            recordingManager.startRecording()
            isRecording = true
            timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] date in
                    if let startTime = self?.recordingDate {
                        self?.currentDuration = startTime.distance(to: date)
                    }
                }
            // set audio data
            recordingName = "New Recording \(Date().formatted())"
            recordingParentTitle = folderTitle
            recordingDate = Date()
            recordingParent = parentID
            recordingDuration = 0
            currentDuration = 0
            recordingURLFileName = fileName
            
        case .failure(let err):
                hasError = true
                error = err
        }
    }
    
    private func handleStopRecordingError(result: Result<Void, RecordingError> ) {
        switch(result){
        case .success:
            isRecording = false
            print("setting isRecording = false")
        case .failure(let err):
            hasError = true
            error = err
            print("ending recording caused an error")
        }
    }
    
    func stopRecording() {
        if !isRecording { return }
        let result = recordingManager.stopRecording()
        recordingDuration = recordingDate.distance(to: Date())
        timerSubscription?.cancel()
        timerSubscription = nil
        print("timer subscription cancelled")
        handleStopRecordingError(result: result)
        addFile()
    }
    
    private func addFile() {
        if hasError { return }
        if let recordingURLFileName {
            database.addFile(fileName: recordingName, date: recordingDate,
                             parentID: recordingParent, duration: recordingDuration, recordingURLFileName: recordingURLFileName)
            .sink (
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        self.hasError = true
                        self.error = error
                        print("Received error: \(error)")
                    case .finished:
                        print("sucess")
                    }
                }, receiveValue: { [weak self] in
                    self?.onFileAdded.send()
                }
            )
            .store(in: &cancellables)
        }
    }
}
