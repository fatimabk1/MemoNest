//
//  ContentView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ContentView: View {
    let database = MockDataManager()
    var body: some View {
        NavigationStack {
            FolderListView(currentFolder: nil, database: database)
        }
    }
}

#Preview {
    ContentView()
}
