//
//  TitleIconProtocol.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

protocol NameIconProtocol {
    var id: UUID { get }
    var name: String { get }
    var icon: String { get }
}
