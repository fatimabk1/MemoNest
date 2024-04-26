//
//  Item.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation
import RealmSwift


enum ItemType: String, PersistableEnum {
    case folder, recording
    
    func icon() -> String {
        switch(self) {
        case .folder:
            "folder.fill"
        case .recording:
            "headphones"
        }
    }
}

struct Item {
    let id: UUID
    var name: String
    var parent: UUID?
    var date: Date
    var type: ItemType
    var audioInfo: AudioMetaData? = nil
        
    init(id: UUID = UUID(), name: String, parent: UUID? = nil, date: Date = Date(), type: ItemType, audioInfo: AudioMetaData? = nil) {
        self.id = id
        self.name = name
        self.parent = parent
        self.date = date
        self.type = type
        self.audioInfo = audioInfo
    }
    
    func isFolder() -> Bool {
        return self.type == .folder
    }
    
    func isAudio() -> Bool {
        return self.type == .recording
    }
    
    func getIcon() -> String {
        return type.icon()
    }
}

struct AudioMetaData {
    let duration: TimeInterval
    let recordingURLFileName: String
}

extension Item {
    static let sampleAudioInfo = AudioMetaData(duration: TimeInterval(25), recordingURLFileName: "https://www.sampleURL.com")
    static let sampleRecording = Item(name: "Recording #1", parent: nil, date: Date(), type: .recording, audioInfo: sampleAudioInfo)
}
