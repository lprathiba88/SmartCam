//
//  TripDetailsViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/3/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AVKit

class TripDetailsViewController: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var startLocation: UILabel!
    @IBOutlet weak var stopLocation: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stopTime: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var eventThumbnail: UIImageView!
    
    var tripDetails: UserDetails?
    var videoAsset: AVAsset?
    
    @IBAction func playVideo(_ sender: Any) {
        if let asset = videoAsset {
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            player.allowsExternalPlayback = false
            
            let playerViewCOntroller = AVPlayerViewController()
            playerViewCOntroller.player = player
            
            present(playerViewCOntroller, animated: true, completion: {
                playerViewCOntroller.player!.play()
            })
        }
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        guard let details = tripDetails else { return }
        
        let tripName = details.tripName.components(separatedBy: "PM").first!.appending("PM")
        
        self.tripName.text = tripName
        
        if details.videoURL.count > 0 {
            let videoLocalId = details.videoURL[0]
            self.playButton.isHidden = false
            loadMovie(for: videoLocalId) { (asset) in
                if let asset = asset {
                    self.videoAsset = asset
                    self.eventThumbnail.image = self.previewImageFromVideo(asset)
                }
            }
        }
        else {
            self.playButton.isHidden = true
        }
        
        
        let locationDetails = details.tripDetails
        
        self.startLocation.text = "\(locationDetails[0].latitude), \(locationDetails[0].longitude)"
        self.stopLocation.text = "\(locationDetails[locationDetails.count - 1].latitude), \(locationDetails[locationDetails.count - 1].longitude)"
        self.startTime.text = locationDetails[0].dateAndTime.components(separatedBy: "+0000").first!
        self.stopTime.text = locationDetails[locationDetails.count - 1].dateAndTime.components(separatedBy: "+0000").first!
        
        // calculate average speed
        var totalSpeed = 0.0
        for i in locationDetails {
            totalSpeed += i.speed
        }
        self.averageSpeed.text = String(totalSpeed/Double(locationDetails.count)) + "mph"
        
    }
    
    func loadMovie(for localIdentifier: String, completion: @escaping (AVAsset?) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        let fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: fetchOptions)
        
        if fetchResults.count > 0 {
            if let videoAsset = fetchResults.firstObject {
                let requestOptions = PHVideoRequestOptions()
                requestOptions.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestAVAsset(forVideo: videoAsset, options: requestOptions, resultHandler: { (avAsset, avAudioMix, info) in
                    completion(avAsset)
                })
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    func previewImageFromVideo(_ asset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }


}
