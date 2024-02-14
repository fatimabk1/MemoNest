//
//  PlayBackView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct PlayBackView: View {
    let file: File
    var body: some View {
        ZStack {
            Color.white
            Text(file.name)
                .font(.largeTitle)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PlayBackView(file: File(name: "File A", folder: nil))
}
