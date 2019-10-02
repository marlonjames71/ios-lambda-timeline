//
//  AudioPlayer.swift
//  LambdaTimeline
//
//  Created by Marlon Raskin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate {
    func playerDidChangeState(_ player: AudioPlayer)
}

class AudioPlayer: NSObject {

    // MARK: - Computed & Non-computed properties

    var audioPlayer: AVAudioPlayer
    var delegate: AudioPlayerDelegate?
    var timer: Timer?

    var isPlaying: Bool {
        audioPlayer.isPlaying
    }

    var currentTime: TimeInterval {
        audioPlayer.currentTime
    }

    var timeRemaining: TimeInterval {
        duration - currentTime
    }

    var duration: TimeInterval {
        audioPlayer.duration
    }

    // MARK: - Init()

    override init() {
        self.audioPlayer = AVAudioPlayer()
        super.init()

        let song = Bundle.main.url(forResource: "piano", withExtension: "mp3")!
        try! loadAudio(with: song)
    }

    // MARK: - Player Functions

    func loadAudio(with url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
    }

    func play() {
        audioPlayer.play()
        startTimer()
        notifyDelegate()
    }

    func pause() {
        audioPlayer.pause()
        stopTimer()
        notifyDelegate()
    }

    func playPause() {
        isPlaying ? pause() : play()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            self.notifyDelegate()
        })
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Notification

    private func notifyDelegate() {
        delegate?.playerDidChangeState(self)
    }
}
