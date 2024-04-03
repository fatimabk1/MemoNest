//
//  AudioRecording.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation

final class AudioRecording {
    let id = UUID()
    var name: String
    var parent: UUID?
    var date: Date = Date() // skip time, because date type includes date and time
    let icon = "headphones"
    let length: TimeInterval
    let recordingURL: URL
    
    init(name: String="\(Date().formatted()) Recording", parent: UUID?, date: Date, length: TimeInterval, recordingURL: URL) {
        self.name = name
        self.parent = parent
        self.date = date
        self.length = length
        self.recordingURL = recordingURL
    }
}

extension AudioRecording {
    static let sample = AudioRecording(name: "Recording #1", parent: nil, date: Date(), length: TimeInterval(25), recordingURL: URL(string: "https://www.sampleURL.com")!)
}
