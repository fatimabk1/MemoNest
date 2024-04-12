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
    @State var showing = false
    
    init() {
        self.viewModel = PlaygroundTestingViewModel()
    }
    
    var body: some View {
        List {
            ForEach(0..<10) { num in
                VStack {
                    HStack {
                        Text("hi")
                        Button("Button") {
//                            withAnimation {
                                showing.toggle()
//                            }
                        }
                    }
                    if showing {
                        Text("here")
                        Text("here")
                        Text("here")
                        Text("here")
//                            .transition(.move(edge: .top)).transition(.move(edge: .bottom))
                    }
                }
            }
        }
    }
}

#Preview {
    PlaygroundTesting()
}
