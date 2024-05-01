//
//  RecordingData.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


struct RecordingData {
    var recordingDate: Date = Date()
    var recordingParent: UUID? = nil
    var recordingDuration: TimeInterval = 0
    var recordingURLFileName: String?
}
