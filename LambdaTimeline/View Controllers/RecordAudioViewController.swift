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
    @IBOutlet private weak var remainingTimeLabel: UILabel!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var cancelButton: UIBarButtonItem!
    @IBOutlet private weak var postButton: UIBarButtonItem!


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext
    }


    // MARK: - IBActions
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {

    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {

    }

    @IBAction func postButtonTapped(_ sender: UIBarButtonItem) {
        
    }
}
