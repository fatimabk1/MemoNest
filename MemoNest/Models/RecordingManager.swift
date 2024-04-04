//
//  RecordingManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation
import Photos


enum RecordingError: Error {
    case noAudio, unableToOutput, noPermission, selfIsNil, unableToRecord, noSessionQueue
}

final class RecordingManager: NSObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    var audioRecorder: AVAudioRecorder?
    let audioSession: AVAudioSession
    var hasRecordPermission = false
    var audioSessionIsSetup = false
    var filePath: URL?
    
    private var recordingCount = 0
    private let audioSettings =  [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 12000,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    init(audioSession: AVAudioSession) {
        self.audioSession = audioSession
    }
    
    func requestPermission(completion: @escaping(Bool) -> Void) {
        print("Requesting permission")
        AVAudioApplication.requestRecordPermission() { [weak self] permission in
            if permission {
                self?.hasRecordPermission = true
            }
            completion(permission)
        }
    }
    
    func setupAudioSession() {
        print("Setting up audio session")
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Error: cannot setup Audio Session")
        }
    }
    
    func getNewFileName() -> URL {
        print("Generating audio file name")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        recordingCount += 1
        let fileName = paths[0].appendingPathComponent("Recording #\(recordingCount).m4a")
        filePath = fileName
        return fileName
    }
    
    private func setupRecorder() {
        print("Setting up recorder")
        do {
            audioRecorder = try AVAudioRecorder(url: getNewFileName(), settings: audioSettings)
            audioRecorder?.delegate = self
        } catch {
            print("Error: cannot setup recorder")
        }
    }
    
    func startRecording() {
        if hasRecordPermission {
            setupRecorder()
            audioRecorder?.record()
            isRecording = true
            print("Now recording...")
        }
    }
    
    func stopRecording() {
        if isRecording {
            audioRecorder?.stop()
            print("Ending recording")
            audioRecorder = nil
            do {
                try AVAudioSession.sharedInstance().setActive(false)
            } catch {
                print("Error: unable to deactivate audio sesion from recording")
            }
        }
    }
    
}
