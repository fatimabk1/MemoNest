//
//  PlaybackManager.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation
import AVFoundation


final class PlaybackManager {
    @Published var isPlaying = false
    let audioPlayer = AVAudioPlayer()
    let fileURL: URL
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func setupAudioSession() {}
    func setupPlayer() {}
    func playOrPause() {}
}
