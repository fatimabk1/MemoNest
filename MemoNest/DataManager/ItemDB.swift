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
        let recordingURLFileName = audioInfo?.recordingURLFileName
        return ItemDB(id: id, name: name, parent: parent, date: date, typeRaw: type.rawValue, duration: audioInfo?.duration, recordingURLFileName: recordingURLFileName)
    }
}

final class ItemDB: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var parent: UUID?
    @Persisted var date: Date
    @Persisted var typeRaw: String
    @Persisted var duration: TimeInterval?
    @Persisted var recordingURLFileName: String?
    
    init(id: UUID = UUID(), name: String, parent: UUID? = nil, date: Date = Date(), typeRaw: String, duration: TimeInterval? = nil, recordingURLFileName: String? = nil) {
        super.init()
        self.id = id
        self.name = name
        self.parent = parent
        self.date = date
        self.typeRaw = typeRaw
        self.duration = duration
        self.recordingURLFileName = recordingURLFileName
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension ItemDB {
    func asItem() -> Item {
        let type = ItemType(rawValue: typeRaw) ?? .folder // shouldn't fail
        var audioInfo: AudioMetaData? = nil
        if type == .recording, let duration, let recordingURLFileName {
            audioInfo = AudioMetaData(duration: duration, recordingURLFileName: recordingURLFileName)
        }
        return Item(id: id, name: name, parent: parent, date: date, type: type, audioInfo: audioInfo)
    }
}
