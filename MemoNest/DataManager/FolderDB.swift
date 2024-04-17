//
//  FolderDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation
import RealmSwift

class FolderDB: Object {
    let id = UUID()
    var name: String
    var parent: UUID?
    var date: Date = Date()
    let icon = "folder"
    var type: ItemType = .folder
    var audioInfo: AudioMetaData? = nil
    
    init(name: String, parent: UUID? = nil, date: Date, type: ItemType, audioInfo: AudioMetaData? = nil) {
        self.name = name
        self.parent = parent
        self.date = date
        self.type = type
        self.audioInfo = audioInfo
    }
}

extension FolderDB {
    func asFolder() -> Folder {
        return Folder(name: self.name, parent: self.parent)
    }
}
