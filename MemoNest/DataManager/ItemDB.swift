//
//  ItemDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/18/24.
//

import Foundation
import RealmSwift


extension Item {
    func asItemDB() -> ItemDB {
        let recordingURLString = audioInfo?.recordingURL.absoluteString
        return ItemDB(id: id, name: name, parent: parent, date: date, typeRaw: type.rawValue, duration: audioInfo?.duration, recordingURL: recordingURLString)
    }
}

final class ItemDB: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var parent: UUID?
    @Persisted var date: Date
    @Persisted var typeRaw: String
    @Persisted var duration: TimeInterval?
    @Persisted var recordingURL: String?
    
    init(id: UUID = UUID(), name: String, parent: UUID? = nil, date: Date = Date(), typeRaw: String, duration: TimeInterval? = nil, recordingURL: String? = nil) {
        super.init()
        self.id = id
        self.name = name
        self.parent = parent
        self.date = date
        self.typeRaw = typeRaw
        self.duration = duration
        self.recordingURL = recordingURL
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ItemDB {
    func asItem() -> Item {
        var type = ItemType.folder
        var audioInfo: AudioMetaData? = nil
        if typeRaw == "recording", let duration, let recordingURL, let url = URL(string: recordingURL) {
            type = ItemType.recording
            audioInfo = AudioMetaData(duration: duration, recordingURL: url)
        }
        return Item(id: id, name: name, parent: parent, date: date, type: type, audioInfo: audioInfo)
    }
}
