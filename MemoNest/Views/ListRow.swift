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
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: icon)
                Text(name)
            }
        }

    }
}

#Preview {
    ListRow(name: "Folder", icon: "Folder") {}
}
