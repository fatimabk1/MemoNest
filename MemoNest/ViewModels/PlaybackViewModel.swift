//
//  PlaybackViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation

final class PlaybackViewModel: ObservableObject {
    let playbackManager: PlaybackManager
    let recording: AudioRecording
    
    init(recording: AudioRecording) {
        self.recording = recording
        self.playbackManager = PlaybackManager(fileURL: recording.recordingURL)
    }
    
    func rename() {}
    func play() {}
    func pause() {}
    func seek() {}
}
