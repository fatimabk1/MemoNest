//
//  PlaybackManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation

// TODO: switch to using AVPlayer

final class PlaybackManager {
    @Published var isPlaying = false
    let audioSession: AVAudioSession
    var audioPlayer: AVAudioPlayer?
    let fileURL: URL
    
    init(audioSession: AVAudioSession, fileURL: URL) {
        self.audioSession = audioSession
        self.fileURL = fileURL
    }
    
    func play() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.play()
        } catch {
            print("Error: cannot play/pause audio")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Error: unable to deactivate audio sesion  from Playback")
        }
    }
}
