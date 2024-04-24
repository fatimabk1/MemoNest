//
//  ContentView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ContentView: View {
//    let database = RealmDataManager()

    let database = MockDataManager(folders: MockDataManager.sampleFolders, files: [Item(name: "Philosophy Lecture #4, The Self", date: Date(), type: .recording, audioInfo: AudioMetaData(duration: 123, recordingURLFileName: "www.sample.com")), Item(name: "PHilosophy Review nOtes", date: Date(), type: .recording, audioInfo: AudioMetaData(duration: 123, recordingURLFileName: "www.sample.com"))])
    
    var body: some View {
        NavigationStack {
            FolderListView(database: database)
        }
    }
}

#Preview {
    ContentView()
}
