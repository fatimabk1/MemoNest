//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine


enum RecordingError: TitledError {
    case unableToSetupRecorder, unableToDeactivateAudioSession, noPermission, incompleteData
    
    var title: String {
        switch(self){
            
        case .unableToSetupRecorder:
            "Error: Unable to record"
        case .unableToDeactivateAudioSession:
            "Error: Unable to record"
        case .noPermission:
            "Please visit Settings to enable recording permission."
        case .incompleteData:
            "Error: Missing data required to save recording."
        }
    }
}

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


final class RecordingService:  NSObject, AVAudioRecorderDelegate {
    private var hasRecordPermission = false
    let status = CurrentValueSubject<RecordingStatus, Never>(.idle)
    private(set) var recordingURLFileName: String!
    private(set) var recordingDate: Date = Date()
    private var cancellables = Set<AnyCancellable>()
    
    var audioRecorder: AVAudioRecorder?
    private let audioSettings =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    init(audioRecorder: AVAudioRecorder? = nil, cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        super.init()
        self.audioRecorder = audioRecorder
        self.cancellables = cancellables
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
        requestPermission { [weak self] granted in
            guard let self else { return }
            self.hasRecordPermission = granted
            completion()
        }
    }
    
    private func requestPermission(completion: @escaping(Bool) -> Void) {
        print("Requesting permission")
        AVAudioApplication.requestRecordPermission() { permission in
            completion(permission)
        }
    }
    
    private func getNewFileName() -> String {
        print("Generating audio file name")
        let unique = UUID()
        let fileName = "\(unique).m4a"
        return fileName
    }
    
    private func getFileURL(fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent(fileName)
        return path
    }
    
    func startRecording(parentID: UUID?, folderTitle: String) {
        checkPermissions() { [weak self] in
            guard let self else { return }
            if !hasRecordPermission {
                status.send(.error(RecordingError.noPermission))
                return
            }
        
            do {
                let fileName = getNewFileName()
                let fileURL = getFileURL(fileName: fileName)
                audioRecorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
                audioRecorder?.prepareToRecord()
                audioRecorder?.delegate = self
               
                recordingDate = Date()
                audioRecorder?.record()
                recordingURLFileName = fileName
                status.send(.recording(recordingDate))
            } catch {
                status.send(.error(RecordingError.unableToSetupRecorder))
            }
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        print("Ending recording")
        audioRecorder = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("deactivated AVAudioSession")
            let recordingDuration = recordingDate.distance(to: Date())
            status.send(.finished(recordingDuration, recordingURLFileName))
        } catch {
            print("Error: unable to deactivate audio sesion from recording")
            status.send(.error(RecordingError.unableToDeactivateAudioSession))
        }
    }
}
