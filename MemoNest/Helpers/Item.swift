//
//  ItemProtocol.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import Foundation

// NOTE: naming should be generic to wrap all items that conform to that protocol
// imagine a superclass/base class / parent
// folderable / listable

// e.g., protocol service with implementation called NetworkService: Service
// So here, maybe struct Folder: Item or Folder: Listable

// Rename to Item
protocol Item {
    var id: UUID { get }
    var name: String { get }
    var icon: String { get }
}

/*
 Folder has metadata of its children to keep the order
- A = A1,A2,f4
   - A1 = f1
       -f1
   - A2 = f2, AA2
       -f2
       - AA2 = f3
           -f3
   - f4
*/

/*
 
 files
 - parent
 - index
 - name
 - isFolder
 
 
 */
