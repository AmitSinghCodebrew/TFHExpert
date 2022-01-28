//
//  AudioPlayer.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 14/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import Foundation
import AVFoundation

final class SKAudioPlayer: NSObject {
    
    typealias AudioProgress = (_ audioStreamingInfo: SKAudioStreamingInfo) -> Void
    typealias Buffering = ((_ value: Bool) -> Void)
    
    static let shared = SKAudioPlayer()
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    public var didFinishedAudio: (() -> Void)?
    
    public func play(for url: URL, currentTime: Float, _ progressHandler: @escaping AudioProgress, _ isBuffering: @escaping Buffering) {
        playerItem = AVPlayerItem.init(url: url)
        player = AVPlayer.init(playerItem: playerItem)
        let seconds : Int64 = Int64(currentTime)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        player?.volume = 1.0
        player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: .main) { [weak self] (CMTime) -> Void in
            if self?.player?.currentItem?.status == .readyToPlay {
                let time: Float64 = CMTimeGetSeconds(self?.player?.currentTime() ?? CMTimeMake(value: 0, timescale: 1)) //Slider current value to be set
                let curretTimeText = self?.stringFromTimeInterval(interval: time) //To be set on label
                let maxValue = CMTimeGetSeconds(self?.playerItem?.asset.duration ?? CMTimeMake(value: 0, timescale: 1)) //Slider max value
                let duration = self?.stringFromTimeInterval(interval: maxValue) // Duration of audio
                progressHandler(SKAudioStreamingInfo.init(Float(maxValue), Float(time), duration, curretTimeText))
            }
            
            let playbackLikelyToKeepUp = self?.player?.currentItem?.isPlaybackLikelyToKeepUp
            if /playbackLikelyToKeepUp { //Stop Loader Buffering Completed
                isBuffering(false)
            } else { //Start Loader Buffering Started
                isBuffering(true)
            }
        }
    }
    
    // Notification Handling
    @objc private func playerItemDidReachEnd(notification: NSNotification) {
        didFinishedAudio?()
    }
    
    // Remove Observer
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func seekAudio(for sliderValue: Float) {
        let seconds : Int64 = Int64(sliderValue)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        if player?.rate == 0 {
            player?.play()
        }
    }
    
    public func pause() {
        if let unwrappedPlayer = player, let observer = timeObserver {
            unwrappedPlayer.pause()
            unwrappedPlayer.removeTimeObserver(observer)
            NotificationCenter.default.removeObserver(self)
            timeObserver = nil
            playerItem = nil
            player = nil
        }
    }
    
    private func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

class SKAudioStreamingInfo: Codable {
    var maxValue: Float? //Slider Max Value
    var currentValue: Float? //Slider Current Value
    var duration: String? //Duration of Audio
    var currentPlayBackTime: String? //Current Palying Time
    var status: SKAudioStatus?
    var isBuffering: Bool?
    
    init(_ _maxValue: Float?, _ _currentValue: Float?, _ _duration: String?, _ _currentTime: String?) {
        maxValue = _maxValue
        currentValue = _currentValue
        duration = _duration
        currentPlayBackTime = _currentTime
    }
}

enum SKAudioStatus: String, Codable, CaseIterableDefaultsLast {
    case Playing
    case Paused
}
