//
//  RecordingManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation
import Combine


enum RecordingError: Error {
    case unableToSetupRecorder, unableToDeactivateAudioSession, noPermission
    
    var title: String {
        switch(self){
            
        case .unableToSetupRecorder:
            "Error: Unable to record"
        case .unableToDeactivateAudioSession:
            "Error: Unable to record"
        case .noPermission:
            "Please visit Settings to enable recording permission."
        }
    }
}

final class RecordingManager: NSObject, AVAudioRecorderDelegate {
    var audioRecorder: AVAudioRecorder?
    
    private var filePath: URL?
    private var cancellables = Set<AnyCancellable>()
    private var isRecording = false
    private let audioSettings =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    init(audioRecorder: AVAudioRecorder? = nil, filePath: URL? = nil, cancellables: Set<AnyCancellable> = Set<AnyCancellable>()) {
        super.init()
        self.audioRecorder = audioRecorder
        self.filePath = filePath
        self.cancellables = cancellables
        self.handleInterruptions()
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
                        _ = self.stopRecording() // TODO: bubble up errors?
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func requestPermission(completion: @escaping(Bool) -> Void) {
        print("Requesting permission")
        AVAudioApplication.requestRecordPermission() { permission in
            completion(permission)
        }
    }
    
    private func getNewFileName() -> URL {
        print("Generating audio file name")
        let unique = UUID()
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let path = paths[0].appendingPathComponent("\(unique).m4a")
        return path
    }
    
    func setupRecorder() -> Result<URL, RecordingError> {
        print("Setting up recorder")
        do {
            filePath = getNewFileName()
            if let filePath {
                audioRecorder = try AVAudioRecorder(url: filePath, settings: audioSettings)
                audioRecorder?.prepareToRecord()
                audioRecorder?.delegate = self
                return .success(filePath)
            }
            // shouldn't get here
            return .failure(RecordingError.unableToSetupRecorder)
            
        } catch(let err) {
            print(err)
            return .failure(RecordingError.unableToSetupRecorder)
        }
    }
    
    func startRecording() {
        audioRecorder?.record()
        self.isRecording = true
        print("Now recording...")
    }
    
    func stopRecording() -> Result<Void, RecordingError> {
        audioRecorder?.stop()
        self.isRecording = false
        print("Ending recording")
        audioRecorder = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            print("deactivated AVAudioSession")
            return .success(())
        } catch {
            print("Error: unable to deactivate audio sesion from recording")
            return .failure(RecordingError.unableToDeactivateAudioSession)
        }
    }
    
}
