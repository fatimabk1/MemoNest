//
//  ContentView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            FolderListView(currentFolder: nil)
        }
    }
}

#Preview {
    ContentView()
}
