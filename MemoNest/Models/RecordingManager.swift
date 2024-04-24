//
//  RecordingManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation
import Combine


enum RecordingError: TitledError {
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
    
    private var cancellables = Set<AnyCancellable>()
    private var isRecording = false
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
    }
    
    func requestPermission(completion: @escaping(Bool) -> Void) {
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
    
    func setupRecorder() -> Result<String, RecordingError> {
        print("Setting up recorder")
        do {
            let fileName = getNewFileName()
            let fileURL = getFileURL(fileName: fileName)
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: audioSettings)
            audioRecorder?.prepareToRecord()
            audioRecorder?.delegate = self
            return .success(fileName)
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
