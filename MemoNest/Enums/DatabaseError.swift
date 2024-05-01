//
//  DatabaseError.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


enum DatabaseError: TitledError {
    case failedDelete, itemNotFound, failedAdd, realmNotInstantiated
    
    var title: String {
        switch(self){
            
        case .failedDelete:
            "Unable to delete. Please try again."
        case .itemNotFound:
            "Item not found. Please try again."
        case .failedAdd:
            "Unable to add item. Please try again."
        case .realmNotInstantiated:
            "Database not instantitated. Please reinstall app."
        }
    }
}
