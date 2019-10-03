//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Marlon Raskin on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {

    // MARK: - Properties & Outlets

    var player: AVAudioPlayer?
    var downloadDataTask: URLSessionDataTask?

    var comment: Comment? {
        didSet {
            downloadAudio()
            updateViews()
        }
    }

    var audioData: Data? {
        didSet {
            guard let audioData = audioData else { return }
            player = try? AVAudioPlayer(data: audioData)
        }
    }

    @IBOutlet weak var commentTypeImageView: UIImageView!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!


    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
        setupCellUI()
    }


    // MARK: - Cell Override

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            guard let audioPlayer = player else { return }
            audioPlayer.play()
        }
    }

    private func downloadAudio() {
        guard let audioURL = comment?.audioURL else { return }
        downloadDataTask?.cancel()
        downloadDataTask = URLSession.shared.dataTask(with: audioURL, completionHandler: { (audioData, _, error) in
            if let error = error {
                NSLog("Error downloading audio data: \(error)")
                return
            }

            DispatchQueue.main.async {
                self.audioData = audioData
            }
        })
        downloadDataTask?.resume()
    }


    // MARK: - Helper methods

    func setupCellUI() {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 80.0, weight: .light)
        commentTypeImageView.preferredSymbolConfiguration = iconConfig

        let textBubbleIcon = UIImage(systemName: "text.bubble", withConfiguration: iconConfig)
        commentTypeImageView.image = textBubbleIcon
    }

    func changeCellIconIf(_ urlExists: Bool) {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 80.0, weight: .light)
        commentTypeImageView.preferredSymbolConfiguration = iconConfig

        let textBubbleIcon = UIImage(systemName: "text.bubble")
        let audioIcon = UIImage(systemName: "waveform.circle", withConfiguration: iconConfig)

        if urlExists {
            commentTypeImageView.image = audioIcon
            commentTypeImageView.tintColor = .systemPink
        } else {
            commentTypeImageView.image = textBubbleIcon
            commentTypeImageView.tintColor = .systemIndigo
        }
    }


    private func updateViews() {
        guard let comment = comment else { return }

        authorLabel.text = comment.author.displayName

        if comment.audioURL != nil {
            changeCellIconIf(true)
            commentTextLabel.isHidden = true
        } else {
            changeCellIconIf(false)
            commentTextLabel.text = comment.text
        }
    }
}
