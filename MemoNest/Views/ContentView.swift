//
//  ContentView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI

struct ContentView: View {
    let database = RealmDataManager()
    
    var body: some View {
        FolderListView(database: database)
    }
}

#Preview {
    ContentView()
}
