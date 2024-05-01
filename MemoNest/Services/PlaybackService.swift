//
//  PlaybackViewModel.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/1/24.
//

import Foundation
import AVFoundation
import Combine


final class PlaybackService {
    let status = CurrentValueSubject<PlaybackStatus, Never>(PlaybackStatus.idle)
    var hasError = false
    private var audioPlayer: AVAudioPlayer?
    private var audioWasInterrupted = false
    private var cancellables = Set<AnyCancellable>()

    init() {
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
                guard let userInfo = notification.userInfo,
                    let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                    let type = AVAudioSession.InterruptionType(rawValue: typeValue) else
                {
                    return
                }
                
                switch type {
                case .began:
                    if let isPlaying = self.audioPlayer?.isPlaying, isPlaying, !self.audioWasInterrupted  {
                        self.audioWasInterrupted = true
                        self.pause()
                    }
                case .ended:
                    if self.audioWasInterrupted {
                        self.audioWasInterrupted = false
                        self.play()
                    }
                    
                default:
                    print("Playback DEFAULT case - neither began/ended")
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    func cancelPlayback(recordingID: UUID) {
        pause()
    }
    
    func setupPlayback(item: Item) {
        if let recordingURLFileName = item.audioInfo?.recordingURLFileName {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let path = paths[0].appendingPathComponent(recordingURLFileName)
            setupAudioPlayer(fileURL: path)
        }
    }
    
    private func setupAudioPlayer(fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            let duration = audioPlayer?.duration ?? 0
            audioPlayer?.prepareToPlay()
            status.send(.ready(duration))
        } catch {
            status.send(.error(PlaybackError.cannotCreatePlayerFromURL))
        }
    }
    
    func play() {
        if hasError { return }
        guard let audioPlayer else { return }
        
        if audioPlayer.currentTime == audioPlayer.duration {
            audioPlayer.currentTime = 0
        }
        audioPlayer.play()
        status.send(.playing(audioPlayer.currentTime))
    }
    
    func pause() {
        if hasError { return }
        audioPlayer?.pause()
        status.send(.paused)
    }
    
    func seek(to time: TimeInterval) {
        if hasError { return }
        audioPlayer?.currentTime = time
    }
    
    func seekForward() {
        if let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration {
            var targetTime =  currentTime + 15
            targetTime = targetTime > duration ? duration : targetTime
            seek(to: targetTime)
            status.send(.seek(targetTime))
            
            if targetTime == duration {
                status.send(.paused)
            }
        }
    }
    
    func seekBackward() {
        if let currentTime = audioPlayer?.currentTime {
            var targetTime =  currentTime - 15
            targetTime = targetTime < 0 ? 0 : targetTime
            seek(to: targetTime)
            status.send(.seek(targetTime))
        }
    }
    
}
