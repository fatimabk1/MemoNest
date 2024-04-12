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
    }
    
    private func checkPermissions() {
        recordingManager.requestPermission { [weak self] granted in
            guard let self else { return }
            self.hasRecordPermission = granted
        }
    }
    
    func handleOnAppear() {
        prepareToRecord()
        reset()
    }
    
    func updateParentFolder(parentID: UUID?, folderTitle: String) {
        print("updating parent folder to \(folderTitle)")
        recordingParent = parentID
        recordingParentTitle = folderTitle
    }
    
    private func prepareToRecord() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let result = self.recordingManager.setupRecorder()
            DispatchQueue.main.async {
                switch(result){
                case .success(let fileURL):
                    self.filePath = fileURL
                case .failure(let err):
                    self.error = err
                    self.hasError = true
                }
            }
        }
    }
    
    private func reset() {
        recordingName = "New Recording \(Date().formatted())"
        recordingParentTitle = "Library"
        recordingDate = Date()
        recordingParent = nil
        recordingDuration = 0
        currentDuration = 0
    }
    
    func startRecording(parentID: UUID?, folderTitle: String) {
        checkPermissions()
        if !hasRecordPermission {
            hasError = true
            error = RecordingError.noPermission
            return
        }
        isRecording = true
        
        if filePath != nil {
            recordingManager.startRecording()
            timerSubscription = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] date in
                    if let startTime = self?.recordingDate {
                        self?.currentDuration = startTime.distance(to: date)
                    }
                }
            isRecording = true
        } else {
            let result = recordingManager.setupRecorder()
            switch(result){
            case .success(_):
                recordingManager.startRecording()
                isRecording = true
            case .failure(let err):
                hasError = true
                error = err
                return
            }
        }
        
        updateParentFolder(parentID: parentID, folderTitle: folderTitle)
        recordingDate = Date()
        recordingURL = filePath!
    }
    
    func stopRecording() {
        if !isRecording { return }
        let result = recordingManager.stopRecording()
        recordingDuration = recordingDate.distance(to: Date())
        timerSubscription?.cancel()
        timerSubscription = nil
        
        switch(result){
        case .success:
            isRecording = false
            if filePath != nil{
                addFile()
            }
            self.filePath = nil
        case .failure(let err):
            hasError = true
            error = err
        }
        prepareToRecord()
        reset()
    }
    
    func addFile() {
        if let recordingURL {
            database.addFile(fileName: recordingName, date: recordingDate,
                             parentID: recordingParent, duration: recordingDuration, recordingURL: recordingURL)
            .sink {}
            .store(in: &cancellables)
        }
    }
    
    func rename() {}
    func addRecording() {}
    func saveToFolder() {}
}
