//
//  VideoPlayerView.swift
//  LambdaTimeline
//
//  Created by Marlon Raskin on 10/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    var videoURL: URL? {
        didSet {
            updateViews()
        }
    }

    var videoLayer: AVPlayerLayer?
    var player: AVPlayer?

//    func playVideo(url: URL) {
//
//
//        var topRect = self.view.bounds
//        topRect.size.height /= 4
//        topRect.size.width /= 4
//        topRect.origin.y = view.layoutMargins.top
//
//        playerLayer.frame = topRect
//        view.layer.addSublayer(playerLayer)
//
//        player?.play()
//    }

    private func replayRecording() {
        if let player = player {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }

    private func updateViews() {
        guard let videoURL = videoURL else { return }
        player = AVPlayer(url: videoURL)
        let newVideoLayer = AVPlayerLayer(player: player)
        videoLayer = newVideoLayer
        newVideoLayer.frame = bounds
        layer.addSublayer(newVideoLayer)
        player?.play()
    }



    
}
