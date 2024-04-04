//
//  ContentView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ContentView: View {
    let database = MockDataManager(folders: MockDataManager.sampleFolders,files: MockDataManager.sampleFiles)
    var body: some View {
        NavigationStack {
//            FolderListView(database: database)
            RecordingView()
        }
    }
}

#Preview {
    ContentView()
}
