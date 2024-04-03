//
//  PopupInput.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/2/24.
//

import Foundation


struct PopupInput {
    let popupTitle: String
    let prompt: String
    let placeholder: String
    
    init(popupTitle: String = "", prompt: String = "", placeholder: String = "") {
        self.popupTitle = popupTitle
        self.prompt = prompt
        self.placeholder = placeholder
    }
}
