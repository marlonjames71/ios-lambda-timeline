//
//  VideoCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Marlon Raskin on 10/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {

    var post: Post? {
        didSet {

        }
    }

    var videoURL: URL? {
        didSet {

        }
    }
    
    @IBOutlet private weak var videoPlayerView: VideoPlayerView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!


    




}
