//
//  RecordingError.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 5/1/24.
//

import Foundation


enum RecordingError: TitledError {
    case unableToSetupRecorder, unableToDeactivateAudioSession, noPermission, incompleteData, missingFileURLName
    
    var title: String {
        switch(self){
            
        case .unableToSetupRecorder:
            "Error: Unable to record"
        case .unableToDeactivateAudioSession:
            "Error: Unable to record"
        case .noPermission:
            "Please visit Settings to enable recording permission"
        case .incompleteData:
            "Error: Missing data required to save recording"
        case .missingFileURLName:
            "Error: Cannot save file due to missing file URL"
        }
    }
}
