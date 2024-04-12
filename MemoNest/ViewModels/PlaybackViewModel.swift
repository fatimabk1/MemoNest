//
//  PlaybackViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine

enum PlaybackError: Error {
    case cannotCreatePlayerFromURL
    
    var title: String {
        "Error: cannot play file"
    }
}

final class PlaybackViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0 {
        willSet {
            if newValue >= duration && duration != 0 {
                isPlaying = false
            }
        }
    }
    @Published var duration: TimeInterval = 0
    @Published var hasError = false
    @Published var error: PlaybackError?
    @Published var title: String
    
    let recording: AudioRecording
    private var audioPlayer: AVAudioPlayer?
    private var audioWasInterrupted = false
    private var cancellables = Set<AnyCancellable>()
    
    var icon: String { recording.icon }
    var formattedDuration: String {
        FormatterService.formatTimeInterval(seconds: duration)
    }
    
    init(recording: AudioRecording) {
        self.recording = recording
        self.title = recording.name
        self.handleAudioRouteChanges()
        self.handleInterruptions()
    }
    
    private func handleAudioRouteChanges() {
        NotificationCenter.default.publisher(for: AVAudioSession.routeChangeNotification)
            .sink { notification in
                guard let reason = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt else {
                    return
                }
                switch AVAudioSession.RouteChangeReason(rawValue: reason) {
                case .newDeviceAvailable:
                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                case .oldDeviceUnavailable:
                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleInterruptions() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { notification in
                guard let reason = notification.userInfo?[AVAudioSession.interruptionNotification] as? UInt else {
                    return
                }
                
                switch AVAudioSession.InterruptionType(rawValue: reason) {
                case .began:
                    if self.isPlaying {
                        self.audioWasInterrupted = true
                        self.pause()
                    }
                case .ended:
                    if self.audioWasInterrupted {
                        self.audioWasInterrupted = false
                        self.play()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func handleOnAppear() {
        if let recordingURL = recording.audioInfo?.recordingURL {
            let result = setupAudioPlayer(fileURL: recordingURL)
            switch(result){
            case .success:
                return
            case .failure(let err):
                self.error = err
            }
        }
    }
    
    private func setupAudioPlayer(fileURL: URL) -> Result<Void, PlaybackError> {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
            return .success(())
        } catch {
            print("Error setting up audio player")
            return .failure(PlaybackError.cannotCreatePlayerFromURL)
        }
    }
    
    func play() {
        if hasError { return }
        audioPlayer?.play()
        isPlaying = true
        
        // keep current time synced with audio play time
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let audioPlayer = self?.audioPlayer else { return }
            self?.currentTime = audioPlayer.currentTime
        }
    }
    
    func pause() {
        if hasError { return }
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval) {
        if hasError { return }
            audioPlayer?.currentTime = time
    }
    
    func seekForward() {
        if let currentTime = audioPlayer?.currentTime {
            seek(to: currentTime + 15)
        }
    }
    
    func seekBackward() {
        if let currentTime = audioPlayer?.currentTime {
            seek(to: currentTime - 15)
        }
    }
        
}
