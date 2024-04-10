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
    @Published var fileArray = [URL]()
    @Published var filePath: URL?
    
    var recordingManager: RecordingManager
    var hasRecordPermission = false
    let database: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // Variables to hold audio recording data before creation
    var recordingName: String = "New Recording \(Date())"
    var recordingDate: Date = Date()
    var recordingParent: UUID? = nil
    var recordingDuration: TimeInterval = 0
    var recordingURL: URL = URL(string: "www.sample.com")!
    

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
    
    func startRecording(parentID: UUID?) {
        checkPermissions()
        if !hasRecordPermission {
            hasError = true
            error = RecordingError.noPermission
            return
        }
        isRecording = true
        
        if filePath != nil {
            recordingManager.startRecording()
            isRecording = true
        } else {
            let result = recordingManager.setupRecorder()
            switch(result){
            case .success(let fileURL):
                self.fileArray.append(fileURL)
                recordingManager.startRecording()
                isRecording = true
            case .failure(let err):
                hasError = true
                error = err
                return
            }
        }
        
        recordingParent = parentID
        recordingDate = Date()
        recordingURL = filePath!
    }
    
    // TODO:
    /*
     - need to take file name as input or have default name recording #x
     */
    
    func stopRecording(currentFolder: UUID?) {
        if !isRecording { return }
        let result = recordingManager.stopRecording()
        recordingDuration = recordingDate.distance(to: Date())
        
        switch(result){
        case .success:
            isRecording = false
            if filePath != nil{
                addFile(currentFolder: currentFolder)
            }
            self.filePath = nil
        case .failure(let err):
            hasError = true
            error = err
        }
    }
    
    func addFile(currentFolder: UUID?) {
        database.addFile(fileName: recordingName, date: recordingDate,
                         parentID: recordingParent, duration: recordingDuration, recordingURL: recordingURL)
            .sink {}
            .store(in: &cancellables)
    }
    
    func rename() {}
    func addRecording() {}
    func saveToFolder() {}
}
