//
//  ItemType.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation
import RealmSwift

enum ItemType: String, PersistableEnum {
    case folder, recording
    
    func icon() -> String {
        switch(self) {
        case .folder:
            "folder.fill"
        case .recording:
            "headphones"
        }
    }
}
