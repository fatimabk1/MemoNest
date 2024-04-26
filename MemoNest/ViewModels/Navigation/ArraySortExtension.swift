//
//  ArraySortExtension.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/26/24.
//

import Foundation


extension Array where Element == Item {
    func sortedByName() -> [Element] {
        return self.sorted(by: { a, b in
            a.name < b.name
        })
    }
    
    func sortedByDateAsc() -> [Element] {
        return self.sorted(by: { a, b in
            a.date < b.date
        })
    }
    
    func sortedByDateDesc() -> [Element] {
        return self.sorted(by: { a, b in
            a.date > b.date
        })
    }
}
