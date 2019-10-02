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
//        timeRemainingLabel.text = timeFormatter.string(from: player.timeRemaining)

        if player.isPlaying {
            UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: [.repeat, .autoreverse], animations: {
                self.playPauseButton.tintColor = UIColor(red: 0.01, green: 1.00, blue: 0.79, alpha: 1.00)
            }, completion: nil)
        } else {
            playPauseButton.tintColor = .systemTeal
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
