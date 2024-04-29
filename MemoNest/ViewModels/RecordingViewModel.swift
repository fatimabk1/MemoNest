//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine


enum RecordingStatus {
    case recording(Date)
    case finished(TimeInterval, String)
    case idle
    case error(TitledError)
    
    var isRecording: Bool {
        if case .recording = self {
            return true
        }
        return false
    }
}


final class RecordingService {
    private var recordingManager: RecordingManager
    private var hasRecordPermission = false
    let status = CurrentValueSubject<RecordingStatus, Never>(.idle)
    private(set) var recordingURLFileName: String!
    private(set) var recordingDate: Date = Date()
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
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
                    if self.status.value.isRecording {
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
    
    private func checkPermissions(completion: @escaping () -> Void) {
        recordingManager.requestPermission { [weak self] granted in
            guard let self else { return }
            self.hasRecordPermission = granted
            completion()
        }
    }
    
    func startRecording(parentID: UUID?, folderTitle: String) {
        checkPermissions() { [weak self] in
            guard let self else { return }
            if !hasRecordPermission {
                status.send(.error(RecordingError.noPermission))
                return
            }
        
            let result = recordingManager.setupRecorder()
            switch result {
            case .success(let fileName):
                recordingDate = Date()
                recordingManager.startRecording()
                recordingURLFileName = fileName
                status.send(.recording(recordingDate))
            case .failure(let err):
                status.send(.error(err))
            }
        }
    }
    
    func stopRecording() {
        let result = recordingManager.stopRecording()
        if case let .failure(err) = result {
            status.send(.error(err))
            return
        }
        let recordingDuration = recordingDate.distance(to: Date())
        status.send(.finished(recordingDuration, recordingURLFileName))
    }
}
