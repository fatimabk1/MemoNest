//
//  MemoNestApp.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 2/14/24.
//

import SwiftUI
import AVFoundation

@main
struct MemoNestApp: App {
    
    init(){
        setupAudioSession()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    func setupAudioSession() {
        print("Setting up audio session")
        let audioSession = AVAudioSession()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.overrideOutputAudioPort(.speaker)
            try audioSession.setActive(true)
        } catch {
            print("Error: cannot setup Audio Session")
        }
    }
}
