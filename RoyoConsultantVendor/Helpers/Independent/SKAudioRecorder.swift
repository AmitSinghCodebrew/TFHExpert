//
//  SKAudioRecorder.swift
//  RoyoConsultant
//
//  Created by Sandeep Kumar on 15/01/21.
//  Copyright © 2021 SandsHellCreations. All rights reserved.
//

import Foundation
import AVFoundation

enum RecordingStatus {
    case Recording
    case Canceled
    case Finished
    case Idle
}

final class SKAudioRecorder: NSObject {
    
    enum RequestStatus {
        case Granted
        case NotAuthorized
        case Error(description: String)
        case RecordingStarted
    }
    
    private var recordingSession: AVAudioSession?
    private var recorder: AVAudioRecorder?
    private var meterTimer: Timer?
    private var recorderApc0: Float = 0
    private var recorderPeak0: Float = 0
    //PLayer
    private var player: AVAudioPlayer?
    private var savedFileURL: URL?
    
    static let shared = SKAudioRecorder()
    
    private func setup(_ status: ((_ _status: RequestStatus) -> Void)?) {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(AVAudioSession.Category.playAndRecord, options: .defaultToSpeaker)
            try recordingSession?.setActive(true)
            recordingSession?.requestRecordPermission({ (allowed) in
                if allowed {
                    status?(.Granted)
                } else {
                    status?(.NotAuthorized)
                }
            })
        } catch {
            status?(.Error(description: error.localizedDescription))
        }
    }

    func record(fileName: String, _ status: ((_ _status: RequestStatus) -> Void)?) {
        setup { [weak self] (setupStatus) in
            switch setupStatus {
            case .Granted:
                let url = self?.getUserPath().appendingPathComponent(fileName + ".m4a")
                let audioURL = URL.init(fileURLWithPath: /url?.path)
                let recordSettings: [String: Any] = [AVFormatIDKey: kAudioFormatMPEG4AAC,
                                                     AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                                                     AVNumberOfChannelsKey: 2,
                                                     AVSampleRateKey: 44100.0]
                do {
                    self?.recorder = try AVAudioRecorder.init(url: audioURL, settings: recordSettings)
                    self?.recorder?.delegate = self
                    self?.recorder?.isMeteringEnabled = true
                    self?.recorder?.prepareToRecord()
                    self?.recorder?.record()
                    self?.meterTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer: Timer) in
                        //Update Recording Meter Values so we can track voice loudness
                        if let recorder = self?.recorder {
                            recorder.updateMeters()
                            self?.recorderApc0 = recorder.averagePower(forChannel: 0)
                            self?.recorderPeak0 = recorder.peakPower(forChannel: 0)
                        }
                    })
                    self?.savedFileURL = url
                    status?(.RecordingStarted)
                } catch {
                    status?(.Error(description: error.localizedDescription))
                }
            case .NotAuthorized:
                status?(.NotAuthorized)
            case .Error(_):
                status?(setupStatus)
            case .RecordingStarted:
                status?(.RecordingStarted)
            }
        }
       
    }
    
    private func getUserPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func finishRecording(fileURLGet: ((_ url: String) -> Void)?) {
        recorder?.stop()
        self.meterTimer?.invalidate()
        var fileURL: String?
        if let url: URL = recorder?.url {
            fileURL = String(describing: url)
            fileURLGet?(/fileURL)
        }
    }
    
    //Player
    func setupPlayer(_ url: URL) {
        do {
            try player = AVAudioPlayer.init(contentsOf: url)
        } catch {
            print("Error1", error.localizedDescription)
        }
        player?.prepareToPlay()
        player?.play()
        player?.volume = 1.0
        player?.delegate = self
    }

}
//MARK:- AVAudioRecorderDelegate
extension SKAudioRecorder: AVAudioRecorderDelegate {
    internal func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        debugPrint("AudioManager Finish Recording")
    }
    
    internal func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        debugPrint("Encoding Error", /error?.localizedDescription)
    }
}

//MARK:- AVAudioRecorderDelegate
extension SKAudioRecorder: AVAudioPlayerDelegate {
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()
    }
    
    internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        debugPrint(/error?.localizedDescription)
    }
}
