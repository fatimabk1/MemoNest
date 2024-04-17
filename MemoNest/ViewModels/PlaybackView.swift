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
        VStack(spacing: 0) {
            Text("\(FormatterService.formatTimeInterval(seconds: viewModel.currentTime))")
                .frame(maxWidth: 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
            if viewModel.duration > 0 {
                Slider(value: $viewModel.currentTime,
                       in: 0...viewModel.duration,
                       step: 0.1,
                       onEditingChanged: { editing in
                    if !editing {
                        viewModel.seek(to: viewModel.currentTime)
                    }
                })
                .tint(Color.blue)
            }
            
            HStack(spacing: 50) {
                Spacer()
                seekBackwardButton
                playPauseButton
                seekForwardButton
                Spacer()
            }
            .padding(.top)
        }
        .padding()
        .alert(isPresented: $viewModel.hasError) {
            Alert(title: Text("\(viewModel.error?.title ?? "")"))
        }
        .onAppear {
            viewModel.handleOnAppear()
        }
    }
    
    private var playPauseButton: some View {
        Button {
            if !viewModel.isPlaying {
                viewModel.play()
            } else {
                viewModel.pause()
            }
        } label: {
            Image(systemName: viewModel.isPlaying ? "pause.circle" : "play.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
    }
    
    private var seekForwardButton: some View {
        Button {
            if viewModel.isPlaying {
                viewModel.seekForward()
            }
        } label: {
            Image(systemName: "forward.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
    }
    
    private var seekBackwardButton: some View {
        Button {
            if viewModel.isPlaying {
                viewModel.seekBackward()
            }
        } label: {
            Image(systemName: "backward.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        PlaybackView(recording: AudioRecording.sample)
    }
}
