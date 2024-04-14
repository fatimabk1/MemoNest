//
//  ItemProtocol.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

enum ItemType {
    case folder, recording
}
 
protocol Item {
    var id: UUID { get }
    var name: String { get }
    var icon: String { get }
    var date: Date { get }
    var parent: UUID? { get }
    var type: ItemType {get}
    var audioInfo: AudioMetaData? {get}
}

