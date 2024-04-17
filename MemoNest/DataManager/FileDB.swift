//
//  FileDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation


//struct AudioMetaData {
//    let duration: TimeInterval
//    let recordingURL:URL
//}
//
//
struct AudioRecordingDB{
    let id = UUID()
    var name: String
    let icon = "headphones"
    var date: Date = Date() // skip time, because date type includes date and time
    var parent: UUID?
    var type: ItemType = .recording
    var audioInfo: AudioMetaData?
    
    init(name: String, date: Date, parent: UUID? = nil, duration: TimeInterval, recordingURL: URL) {
        self.name = name
        self.date = date
        self.parent = parent
        self.audioInfo = AudioMetaData(duration: duration, recordingURL: recordingURL)
    }
}

extension AudioRecordingDB {
    func asAudioRecording() -> AudioRecording {
        let file = AudioRecording()
    }
}
