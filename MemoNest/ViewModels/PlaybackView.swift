//
//  PlaybackView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import SwiftUI
import AVFoundation

struct PlaybackView: View {
    @ObservedObject var viewModel: PlaybackViewModel
    @State private var debouncedTime: TimeInterval = 0
    
    init(recording: AudioRecording) {
        self.viewModel = PlaybackViewModel(recording: recording)
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: viewModel.icon)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .font(.title)
                Text(viewModel.title)
                    .font(.title)
            }
            Spacer()
            Slider(value: $viewModel.currentTime,
                   in: 0...viewModel.duration,
                   onEditingChanged: { editing in
                       if !editing {
                           viewModel.seek(to: viewModel.currentTime)
                       }
                    })
                    .padding()
            HStack {
                Text("\(viewModel.currentTime)")
                Spacer()
                Button {
                    if !viewModel.isPlaying {
                        viewModel.play()
                    } else {
                        viewModel.pause()
                    }
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("\(viewModel.error?.title ?? "")"))
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
    }
}

#Preview {
    PlaybackView(recording: AudioRecording.sample)
}
