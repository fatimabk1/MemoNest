//
//  PlaybackView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import SwiftUI

struct PlaybackView: View {
    @ObservedObject var viewModel: PlaybackViewModel
    
    init(recording: AudioRecording) {
        self.viewModel = PlaybackViewModel(recording: recording)
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PlaybackView(recording: AudioRecording.sample)
}
