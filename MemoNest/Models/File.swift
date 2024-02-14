//
//  File.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

struct File: NameIconProtocol {
    let id = UUID()
    var name: String
    var folder: UUID?
    let icon = "headphones"
}
