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
            Slider(value: $viewModel.currentTime, in: 0...viewModel.duration)
                .onChange(of: viewModel.currentTime, {
                    viewModel.seek(to: viewModel.currentTime)
                })
                .padding()
            HStack {
                // TODO: FRAME text to 1/3 of screen so it will wrap (don't push play button as time grows longer) OR ZStack & place on top
                Text("\(viewModel.formatTimeInterval(seconds: 12/*viewModel.currentTime*/))")
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
