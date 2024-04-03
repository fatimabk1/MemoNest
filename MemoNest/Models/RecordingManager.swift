//
//  RecordingManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation

final class RecordingManager {
    @Published var isRecording = false
    let audioRecorder = AVAudioRecorder()
    
    func requestPermission() {}
    func setupAudioSession() {}
    func setupRecorder() {}
    func startRecording() {}
    func stopRecording() {}
}
