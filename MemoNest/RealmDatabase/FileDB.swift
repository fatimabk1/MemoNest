//
//  FileDB.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/6/24.
//

import Foundation

struct FileDB: Item {
    let id = UUID()
    var name: String
    var folder: UUID?
    let icon = "headphones"
}
