//
//  RecordingStatus.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


enum RecordingStatus {
    case recording(Date)
    case finished(TimeInterval, String)
    case idle
    case error(TitledError)
    
    var isRecording: Bool {
        if case .recording = self {
            return true
        }
        return false
    }
}
