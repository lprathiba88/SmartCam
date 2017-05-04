//
//  EventsViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/2/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import AVKit

class EventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventsTableView: UITableView!
    
    var videoURLStrings: [String] = []
    var selectedIndexPath = -1
    var videoAsset: AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDetails.tripsArray.count == 0 {
            Firebase.shared.getTripFromFirebase(UserDetails.devideId) { (trips) in
                guard let pastTrips = trips else {
                    print("No trips in Firebase")
                    return
                }
                UserDetails.tripsArray = pastTrips
                self.getTrips()
                DispatchQueue.main.async {
                    self.eventsTableView.reloadData()
                }
            }
        }
        else {
            getTrips()
        }
    }
    
    func getTrips() {
        videoURLStrings.removeAll()
        for i in UserDetails.tripsArray {
            if i.videoURL.count > 0 {
                print("number of videos: \(i.videoURL.count)")
                let videoURLs = i.videoURL
                
                for j in videoURLs {
                    self.videoURLStrings.append(j)
                }
            }
        }
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(videoURLStrings.count)
        return videoURLStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = eventsTableView.dequeueReusableCell(withIdentifier: "eventsCell", for: indexPath) as! EventsTableViewCell
        
        print("indexPath.row: \(indexPath.row)")
        loadMovie(for: self.videoURLStrings[indexPath.row]) { (asset) in
            if let asset = asset {
                self.videoAsset = asset
                cell.videoThumbnail.image = self.previewImageFromVideo(asset)
            }            
        }
        cell.videoName.text = self.videoURLStrings[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath.row
        
        if selectedIndexPath != -1 {
            //print("selectedUrl[selectedIndexPath]: \(selectedUrl[selectedIndexPath])")
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
    }

}
