//
//  TitledError.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/22/24.
//

import Foundation

protocol TitledError: Error {
    var title: String {get}
}
