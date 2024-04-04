//
//  RecordingView.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import SwiftUI

struct RecordingView: View {
//    @ObservedObject var viewModel: RecordingViewModel
    @State var recordingManager = RecordingManager()
    @State var playbackManager: PlaybackManager?
    
    // TODO: START HERE
    /*
     - create audio session in main app
     - on recordButton, pass db, audioSession to recording manager & navigate to new screen
        - on stop record, save to DB
     - on file click, pass db, audio session to plaback manager & navigate to new screen
     */
    
//    init(database: DataManager) {
//        self.viewModel = RecordingViewModel(database: database)
//    }
    
    var body: some View {
        VStack {
            Text("Recording: \(recordingManager.isRecording ? "true" : "false")")
            Button("Start Recording") {
                recordingManager.startRecording()
            }
            Button("Stop Recording") {
                recordingManager.stopRecording()
            }
            
            Text("Playback")
            Button("start playback") {
                if let fileURL = recordingManager.filePath {
                    playbackManager = PlaybackManager(fileURL: fileURL)
                    playbackManager?.play()
                }
            }
            Button("stop playback") {
                if let playbackManager {
                    playbackManager.stop()
                }
            }
        }
        .onAppear {
            recordingManager.requestPermission { granted in
                if granted {
                    recordingManager.setupAudioSession()
                } else {
                    print("No permission - view")
                }
                
            }
        }
    }
}

#Preview {
    RecordingView()
//    RecordingView(database: MockDataManager())
}
