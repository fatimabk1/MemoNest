//
//  File.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

struct File: Item {    
    let id = UUID()
    var name: String
    var parent: UUID?
    let icon = "headphones"
}

// Adapter pattern
extension File {
    func asFileDB() -> FileDB {
        return FileDB(name: self.name, parent: self.parent)
    }
}
