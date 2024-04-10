////
////  RecordingPlaybackTestView.swift
////  MemoNest
////
////  Created by Fatima Kahbi on 4/4/24.
////
//
//import SwiftUI
//import AVFoundation
//
//
//struct RecordingPlaybackTestView: View {
//    @ObservedObject var recordingViewModel: RecordingViewModel
//    @State var recordingArray: [URL] = []
//    
//    init(database: DataManager) {
//        self.recordingViewModel = RecordingViewModel(database: database)
//    }
//    
//    // TODO: record button should interrupt playback
//    // TODO: playback should not interrupt recording
//    var body: some View {
//        VStack {
//            Text("hasError: \(recordingViewModel.hasError ? "true" : "false")")
//            Text("Recording: \(recordingViewModel.isRecording ? "true" : "false")")
//            Button("\(recordingViewModel.isRecording ? "STOP" : "START" ) Recording") {
//                if !recordingViewModel.isRecording {
//                    recordingViewModel.checkPermissions()
//                    if recordingViewModel.hasRecordPermission {
////                        recordingViewModel.startRecording(urlArray: &recordingArray)
//                    }
//                } else {
//                    recordingViewModel.stopRecording()
//                }
//            }
//            
//            List {
//                Section("Recordings") {
//                    ForEach(recordingArray, id: \.self) { recording in
//                        NavigationLink {
//                            PlaybackView(recording: AudioRecording(length: TimeInterval(30), recordingURL: recording))
//                        } label: {
//                            Text("\(recording)")
//                        }
//                        .disabled(recordingViewModel.isRecording)
//                    }
//                }
//            }
//        }
//        .alert(isPresented: $recordingViewModel.hasError) {
//            Alert(title: Text("\(recordingViewModel.error?.title ?? "")"))
//        }
//    }
//}
//
//#Preview {
//    RecordingPlaybackTestView(database: MockDataManager())
//}
