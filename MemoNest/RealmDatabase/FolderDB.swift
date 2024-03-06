//
//  FolderDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

struct FolderDB: Item {
    let id = UUID()
    var name: String
    var parent: UUID?
    let icon = "folder"
}
