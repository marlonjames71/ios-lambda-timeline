//
//  RecordAudioViewController.swift
//  LambdaTimeline
//
//  Created by Marlon Raskin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class RecordAudioViewController: UIViewController {

    // MARK: - Properties & Outlets

    @IBOutlet private weak var currentTimeLabel: UILabel!
    @IBOutlet private weak var timeRemainingLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var postButton: UIBarButtonItem!

    lazy private var player = AudioPlayer()
    lazy private var recorder = Record()

    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext
        setupFontForTimeLabels()
        updateSlider()
        player.delegate = self
        recorder.delegate = self
    }


    // MARK: - IBActions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        player.playPause()
        updateSlider()
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        recorder.toggleRecord()
        animateRecordButton()
    }

    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        
    }


    // MARK: - Helper Functions

    private func updateSlider() {
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = Float(player.currentTime)
    }

    private func updateViews() {
        updateSlider()
        currentTimeLabel.text = timeFormatter.string(from: player.currentTime)
        timeRemainingLabel.text = timeFormatter.string(from: player.duration)
        animatePlayPauseButton()
    }

    private func animatePlayPauseButton() {
        if player.isPlaying {
            UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                self.playPauseButton.tintColor = UIColor(red: 0.01, green: 1.00, blue: 0.79, alpha: 1.00)
            }, completion: nil)
        } else {
            playPauseButton.tintColor = .systemTeal
        }
    }

    private func animateRecordButton() {
        if recorder.isRecording {
            UIView.animateKeyframes(withDuration: 0.6, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                self.recordButton.tintColor = .systemPink
            }, completion: nil)
        } else {
            recordButton.tintColor = .systemIndigo
        }
    }

    // MARK: - Setup

    func setupFontForTimeLabels() {
        currentTimeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: currentTimeLabel.font.pointSize, weight: .regular)
        timeRemainingLabel.font = UIFont.monospacedDigitSystemFont(ofSize: timeRemainingLabel.font.pointSize, weight: .regular)
    }
}

extension RecordAudioViewController: AudioPlayerDelegate {
    func playerDidChangeState(_ player: AudioPlayer) {
        updateViews()
    }
}

extension RecordAudioViewController: RecorderDelegate {
    func recorderDidChangeState(_ recorder: Record) {
        updateViews()
    }

    func recorderDidFinishSavingFile(_ recorder: Record, url: URL) {
        if !recorder.isRecording {
            do {
                try player.loadAudio(with: url)
            } catch {
                NSLog("Error loading audio with url: \(error)")
            }
        }
    }
}
