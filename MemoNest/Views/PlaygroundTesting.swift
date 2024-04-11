//
//  PlaygroundTesting.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/11/24.
//

import SwiftUI

final class PlaygroundTestingViewModel: ObservableObject {
    @Published var title = "Library"
    
    var myTitle: String {
        return "My title" + title
    }
    
    func updateTitle(_ title: String) {
        self.title = title
    }
}

struct PlaygroundTesting: View {
    @ObservedObject var viewModel: PlaygroundTestingViewModel
    
    init() {
        self.viewModel = PlaygroundTestingViewModel()
    }
    
    var body: some View {
        Text(viewModel.myTitle)
        Button("Change title") {viewModel.updateTitle("A New Title") }
    }
}

#Preview {
    PlaygroundTesting()
}
