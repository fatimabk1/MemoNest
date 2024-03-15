//
//  Folder.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

struct Folder: Item {
    let id = UUID()
    var name: String
    var parent: UUID?
    let icon = "folder"
}

extension Folder {
    func asFolderDB() -> FolderDB {
        return FolderDB(name: self.name, parent: self.parent)
    }
}
