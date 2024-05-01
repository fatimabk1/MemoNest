//
//  PlaybackStatus.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


enum PlaybackStatus {
    case ready(TimeInterval)
    case playing(TimeInterval)
    case paused
    case seek(TimeInterval)
    case idle
    case error(TitledError)
    
    var isPlaying: Bool {
        if case .playing = self {
            return true
        }
        return false
    }
}
