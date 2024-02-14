//
//  Folder.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

struct Folder: NameIconProtocol {
    let id = UUID()
    var name: String
    var parent: UUID?
    let icon = "folder"
}
