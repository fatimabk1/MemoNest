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
    @Published var error: RecordingError?
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
    var recordingURL: URL!
    var formattedDuration: String { FormatterService.formatTimeInterval(seconds: recordingDuration) }
    
    // duration of recording while in progress
    private var timerSubscription: AnyCancellable?
    @Published var currentDuration: TimeInterval = 0
    var formattedcurrentDuration: String { FormatterService.formatTimeInterval(seconds: currentDuration) }
    
    
    init(database: DataManager) {
        self.database = database
        self.recordingManager = RecordingManager()
        handleInterruptions()
    }
    
    private func handleInterruptions() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { notification in
                guard let reason = notification.userInfo?[AVAudioSession.interruptionNotification] as? UInt else {
                    return
                }
                
                switch AVAudioSession.InterruptionType(rawValue: reason){
                case .began:
                    if self.isRecording {
                        print("recording interrupted")
                        self.stopRecording() // TODO: bubble up errors?
                    }
                default:
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
        case .success(let filePath):
            recordingManager.startRecording()
            isRecording = true
            timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .receive(on: DispatchQueue.main)
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
            recordingURL = filePath
            
        case .failure(let err):
                hasError = true
                error = err
        }
    }
    
    func stopRecording() {
        if !isRecording { return }
        let result = recordingManager.stopRecording()
        recordingDuration = recordingDate.distance(to: Date())
        timerSubscription?.cancel()
        timerSubscription = nil
        print("timer subscription cancelled")
        
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
    
    func addFile(completion: @escaping () -> Void) {
        if hasError { return }
        if let recordingURL {
            database.addFile(fileName: recordingName, date: recordingDate,
                             parentID: recordingParent, duration: recordingDuration, recordingURL: recordingURL)
            .sink {
                completion()
            }
            .store(in: &cancellables)
        }
    }
}
