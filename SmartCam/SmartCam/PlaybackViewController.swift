//
//  PlaybackViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 4/24/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class PlaybackViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let url = URL(string: "http://devstreaming.apple.com/videos/wwdc/2016/102w0bsn0ge83qfv7za/102/hls_vod_mvp.m3u8"){
            
            let player = AVPlayer(url: url)
            let controller=AVPlayerViewController()
            controller.player=player
            controller.view.frame = self.view.frame
            self.view.addSubview(controller.view)
            self.addChildViewController(controller)
            player.play()
        }
       // playVideo()
    }

    private func playVideo() {
//        guard let path = Bundle.main.path(forResource: "video", ofType:"m4v") else {
//            debugPrint("video.m4v not found")
//            return
//        }
        
        let url: URL = URL(string: "http://static.videokart.ir/clip/100/480/mp4")!
        
//        let player = AVPlayer(url: URL(fileURLWithPath: url))
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        present(playerController, animated: true) {
            player.play()
        }
    }
}
