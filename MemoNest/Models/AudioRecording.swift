//
//  AudioRecording.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation

struct audioMetaData {
    let duration: TimeInterval
    let recordingURL:URL
}


struct AudioRecording: Item {
    let id = UUID()
    var name: String
    let icon = "headphones"
    var date: Date = Date() // skip time, because date type includes date and time
    var parent: UUID?
    var type: ItemType = .recording
    var audioInfo: audioMetaData?
    
    init(name: String, date: Date, parent: UUID? = nil, duration: TimeInterval, recordingURL: URL) {
        self.name = name
        self.date = date
        self.parent = parent
        self.audioInfo = audioMetaData(duration: duration, recordingURL: recordingURL)
    }
}

extension AudioRecording {
    static let sample = AudioRecording(name: "Recording #1", date: Date(), parent: nil, duration: TimeInterval(25), recordingURL: URL(string: "https://www.sampleURL.com")!)
}
