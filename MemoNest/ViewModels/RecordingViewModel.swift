//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation


final class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var hasError = false
    @Published var error: RecordingError?
    @Published var fileArray = [URL]()
    @Published var filePath: URL?
    
    var recordingManager: RecordingManager
    var hasRecordPermission = false
    let database: DataManager
    
    init(database: DataManager) {
        self.database = database
        self.recordingManager = RecordingManager()
    }
    
    func checkPermissions() {
        recordingManager.requestPermission { [weak self] granted in
            guard let self else { return }
            self.hasRecordPermission = granted
        }
    }
    
    func handleOnAppear() {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let result = self.recordingManager.setupRecorder()
            switch(result){
            case .success(let fileURL):
                self.filePath = fileURL
            case .failure(let err):
                self.error = err
                self.hasError = true
            }
        }
    }
    
    func startRecording(/*urlArray: inout [URL]*/) {
        if !hasRecordPermission { 
            hasError = true
            error = RecordingError.noPermission
            return
        }
        isRecording = true
        
        if let filePath {
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
            }
        }
    }
    
    func stopRecording() {
        if !isRecording { return }
        let result = recordingManager.stopRecording()
        switch(result){
        case .success:
            isRecording = false
            if let filePath {
                self.fileArray.append(filePath)
            }
            self.filePath = nil
        case .failure(let err):
            hasError = true
            error = err
        }
    }
    
    
    func rename() {}
    func addRecording() {}
    func saveToFolder() {}
}
