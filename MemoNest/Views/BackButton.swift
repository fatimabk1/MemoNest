//
//  BackButton.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI

struct BackButton: View {
    let hasParentFolder: Bool
    let backFunction: () -> Void
    
    var body: some View {
        if hasParentFolder {
            Button {
                backFunction()
            } label: {
                Image(systemName: "chevron.backward")
                    .foregroundStyle(Colors.blueVeryLight)
                    .padding(.horizontal)
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    BackButton(hasParentFolder: true, backFunction: {})
}
