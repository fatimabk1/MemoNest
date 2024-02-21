//
//  ListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ListRow: View {
    let name: String
    let icon: String
    
    var body: some View {
        
        HStack {
            Image(systemName: icon)
            Text(name)
        }
    }
}

#Preview {
    ListRow(name: "Folder", icon: "Folder")
}
