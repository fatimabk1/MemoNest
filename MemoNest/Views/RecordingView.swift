////
////  RecordingView.swift
////  MemoNest
////
////  Created by Fatima Kahbi on 4/1/24.
////
//
//import SwiftUI
//
//
//struct RecordingView: View {
////    @ObservedObject var viewModel: RecordingViewModel
//    @State var recordingManager = RecordingManager()
//    @State var playbackManager: PlaybackManager?
//    
//    // TODO: START HERE
//    /*
//     - create audio session in main app
//     @StateOject // unique instance
//     .environmentObject(Obj) // injected, not necessarily unique. Obj needs to live somewhere and persist (e.g., living in UI view means multiple instances)
//     - make a fake main screen for simplicity that displays recordings in recordingArray
//     - on recordButton, pass db, audioSession, recordingArray to recording manager & navigate to new screen
//        - on stop record, save to DB
//     - on file click, pass db, audio session to plaback manager & navigate to new screen
//     Main screen @StateOject (audioSession) --> can subscribe to it
//        -> recording
//        -> playback
//     */
//    
////    init(database: DataManager) {
////        self.viewModel = RecordingViewModel(database: database)
////    }
//    
//    var body: some View {
//        VStack {
//            Text("Recording: \(recordingManager.isRecording ? "true" : "false")")
//            Button("Start Recording") {
//                recordingManager.startRecording()
//            }
//            Button("Stop Recording") {
//                recordingManager.stopRecording()
//            }
//            
//            Text("Playback")
//            Button("start playback") {
//                if let fileURL = recordingManager.filePath {
//                    playbackManager = PlaybackManager(fileURL: fileURL)
//                    playbackManager?.play()
//                }
//            }
//            Button("stop playback") {
//                if let playbackManager {
//                    playbackManager.stop()
//                }
//            }
//        }
//        .onAppear {
//            // never want to wait for callbacks in view
//            recordingManager.requestPermission { granted in // todo viewModel.handleOnAppear()
//                if granted {
//                    recordingManager.setupAudioSession()
//                } else {
//                    print("No permission - view") // set error message
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    RecordingView()
////    RecordingView(database: MockDataManager())
//}
