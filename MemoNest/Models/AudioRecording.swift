//
//  AudioRecording.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation

final class AudioRecording {
    let date: Date // skip time, because date type includes date and time
    let length: TimeInterval
    let recordingURL: URL
    
    init(date: Date, length: TimeInterval, recordingURL: URL) {
        self.date = date
        self.length = length
        self.recordingURL = recordingURL
    }
}

extension AudioRecording {
    static let sample = AudioRecording(date: Date(), length: TimeInterval(25), recordingURL: URL(string: "https://www.sampleURL.com")!)
}
