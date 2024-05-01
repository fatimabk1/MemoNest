//
//  PlaybackError.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


enum PlaybackError: TitledError {
    case cannotCreatePlayerFromURL
    
    var title: String {
        "Error: cannot play file"
    }
}
