//
//  RecordingViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation


final class RecordingViewModel: ObservableObject {
    var recordingManager = RecordingManager()
    let database: DataManager
    
    init(database: DataManager) {
        self.database = database
    }
    
    func rename() {}
    func startRecording() {}
    func stopRecording() {}
    func addRecording() {}
    func saveToFolder() {}
}
