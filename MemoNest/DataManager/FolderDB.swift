//
//  FolderDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

struct FolderDB {
    let id = UUID()
    var name: String
    var parent: UUID?
    let icon = "folder"
}

extension FolderDB {
    func asFolder() -> Folder {
        return Folder(name: self.name, parent: self.parent)
    }
}
