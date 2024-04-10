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
        willSet { newValue
            if newValue == duration && duration != 0 {
                isPlaying = false
            }
        }
    }
    @Published var duration: TimeInterval = 0
    @Published var hasError = false
    @Published var error: PlaybackError?
    
    let recording: AudioRecording
    private var audioPlayer: AVAudioPlayer?
    private var audioWasInterrupted = false
    private var cancellables = Set<AnyCancellable>()
    
    // Data formatted for display
    var title: String { recording.name }
    var icon: String { recording.icon }
    var formattedDate: String {
        let dateFormatter = Date.FormatStyle().day().month().year()
        return recording.date.formatted(dateFormatter)
    }
    
    init(recording: AudioRecording) {
        self.recording = recording
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
        audioPlayer?.play()
        isPlaying = true
        
        // keep current time synced with audio play time
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let audioPlayer = self?.audioPlayer else { return }
            self?.currentTime = audioPlayer.currentTime
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
    
    func rename() {}
    
    func formatTimeInterval(seconds: TimeInterval) -> String {
        // Calculate years, months, days, hours, minutes, and seconds
        let minutes = Int(seconds / 60)
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30  // Assuming 30 days per month
        let years = months / 12
        
        let remainingMonths = months % 12
        let remainingDays = days % 30
        let remainingHours = hours % 24
        let remainingMinutes = minutes % 60
        let remainingSeconds = Int(seconds) % 60
        
        // Create the formatted string
        var formattedTime = ""
        if years > 0 {
            formattedTime += "\(years)y "
        }
        if remainingMonths > 0 {
            formattedTime += "\(remainingMonths)mo "
        }
        if remainingDays > 0 {
            formattedTime += "\(remainingDays)d "
        }
        if remainingHours > 0 {
            formattedTime += String(format: "%02d:", remainingHours)
        }
        formattedTime += String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        
        return formattedTime
    }
    
}
