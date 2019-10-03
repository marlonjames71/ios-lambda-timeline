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

    var player = AVAudioPlayer()

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet weak var commentTypeImageView: UIImageView!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    enum CommentType {
        case text
        case audio
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
        setupCellUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            guard let url = comment?.audioURL else { return }
            let audioData = try! Data(contentsOf: url)

            do {
                player = try AVAudioPlayer(data: audioData)
                player.play()
            } catch {
                NSLog("Error loading url: \(error)")
            }
        }
    }

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
        } else {
            commentTypeImageView.image = textBubbleIcon
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
