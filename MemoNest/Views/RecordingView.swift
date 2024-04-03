//
//  RecordingView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import SwiftUI

struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    
    init(database: DataManager) {
        self.viewModel = RecordingViewModel(database: database)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RecordingView(database: MockDataManager())
}
