//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine


final class RecordingService:  NSObject, AVAudioRecorderDelegate {
    let status = CurrentValueSubject<RecordingStatus, Never>(.idle)
    private let audioSettings =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    var audioRecorder: AVAudioRecorder?
    private var hasRecordPermission = false
    private(set) var recordingURLFileName: String?
    private(set) var recordingDate: Date = Date()
    private var cancellables = Set<AnyCancellable>()
    
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
                    return
                }
                
                switch type{
                case .began:
                    if self.status.value.isRecording {
                        self.stopRecording()
                    }
                default:
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
        AVAudioApplication.requestRecordPermission() { permission in
            completion(permission)
        }
    }
    
    private func getNewFileName() -> String {
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
        audioRecorder = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            let recordingDuration = recordingDate.distance(to: Date())
            if let recordingURLFileName {
                status.send(.finished(recordingDuration, recordingURLFileName))
            } else {
                status.send(.error(RecordingError.missingFileURLName))
            }
        } catch {
            status.send(.error(RecordingError.unableToDeactivateAudioSession))
        }
    }
}
