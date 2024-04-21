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
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var hasError = false
    @Published var error: PlaybackError?
    @Published var title: String
    
    let recording: Item
    var audioPlayer: AVAudioPlayer?
    private var audioWasInterrupted = false
    private var cancellables = Set<AnyCancellable>()
    private var timerSubscription: AnyCancellable?
    
    var formattedDuration: String {
        FormatterService.formatTimeInterval(seconds: duration)
    }
    
    init(recording: Item) {
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
                    print("setting audioPort to none")
                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
                case .oldDeviceUnavailable:
                    print("setting audioPort to speakers")
                    try? AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                default:
                    print(AVAudioSession.RouteChangeReason(rawValue: reason) ?? "No route change found")
                    print("defaulting audioport")
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
                    if let isPlaying = self.audioPlayer?.isPlaying, isPlaying  {
                        self.audioWasInterrupted = true
                        self.pause()
                    }
                case .ended:
                    print("audio interruption ended")
                    if self.audioWasInterrupted {
                        print("now playing again")
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
        if let recordingURLFileName = recording.audioInfo?.recordingURLFileName {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let path = paths[0].appendingPathComponent(recordingURLFileName)
            
            let result = setupAudioPlayer(fileURL: path)
            switch(result){
            case .success:
                return
            case .failure(let err):
                self.error = err
                self.hasError = true
            }
        }
    }
    
    private func setupAudioPlayer(fileURL: URL) -> Result<Void, PlaybackError> {
        do {
            print("setup Audio player fileURL: \(fileURL)")
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
            return .success(())
        } catch (let err) {
            print(err)
            print(audioPlayer ?? "failed audio player?")
            print("Error setting up audio player")
            return .failure(PlaybackError.cannotCreatePlayerFromURL)
        }
    }
    
    func play() {
        if hasError { return }
        
        // reset time when replaying
        if audioPlayer?.currentTime == audioPlayer?.duration {
            audioPlayer?.currentTime = 0
        }
        
        audioPlayer?.play()
        
        // keep current time synced with audio play time
        timerSubscription = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                if let audioPlayerCurrentTime = self?.audioPlayer?.currentTime {
                    self?.currentTime = audioPlayerCurrentTime
                    let isCurrentlyPlaying = self?.audioPlayer?.isPlaying ?? false
                    if self?.isPlaying != isCurrentlyPlaying {
                        self?.isPlaying = isCurrentlyPlaying
                    }
                }
            }
    }
    
    func pause() {
        if hasError { return }
        audioPlayer?.pause()
        isPlaying = false
        timerSubscription?.cancel()
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
