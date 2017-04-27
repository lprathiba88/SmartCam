//
//  ViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 4/24/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoViewController: UIViewController {
    
    @IBOutlet weak var camPreview: UIView!
    //@IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    let cameraSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    
    var modeData = [String]()
    let movieOutput = AVCaptureMovieFileOutput()
    var updateTimer: Timer!
    
    @IBAction func onCaptureButton(_ sender: AnyObject) {
        captureMovie()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setupCameraSession() {
            setupPreview()
            startSession()
        }
    }
    
    func setupCameraSession() -> Bool{
        cameraSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // set up camera i.e., capture device
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
                activeInput = deviceInput
            }
        }
        catch {
            print("Error with setting up capture device: \(error)")
            return false
        }
        
        //movie output
        if cameraSession.canAddOutput(movieOutput) {
            cameraSession.addOutput(movieOutput)
        }
        
        return true
    }

    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    func startSession() {
        if !cameraSession.isRunning {
            videoQueue().async {
                self.cameraSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if cameraSession.isRunning {
            videoQueue().async {
                self.cameraSession.stopRunning()
            }
        }
    }
    
    func captureMovie() {
        if !movieOutput.isRecording {
            let filePath = tempURL()
            movieOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
        }
        else {
            movieOutput.stopRecording()
        }
    }
    
    func saveMovieToLibrary(_ movieURL: URL) {
        let photoLibrary = PHPhotoLibrary.shared()
        photoLibrary.performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL)
        }) { (success: Bool, error: Error?) -> Void in
            if success {
                // Set thumbnail
                //self.setVideoThumbnailFromURL(movieURL)
                print("Success writing to movie library!!!")
            } else {
                print("Error writing to movie library: \(error!.localizedDescription)")
            }
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let local_video_name = UUID().uuidString + ".mov"
            let path = directory.appendingPathComponent(local_video_name)
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func formattedCurrentTime(_ time: UInt) -> String {
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        return String(format: "%02i:%02i:%02i", arguments: [hours, minutes, seconds])
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
    }
    
    func startTimer() {
        if updateTimer != nil {
            updateTimer.invalidate()
        }
        
        updateTimer = Timer(timeInterval: 0.5, target: self, selector: #selector(VideoViewController.updateTimeDisplay), userInfo: nil, repeats: true)
        RunLoop.main.add(updateTimer, forMode: RunLoopMode.commonModes)
    }
    
    func updateTimeDisplay() {
        let time = UInt(CMTimeGetSeconds(movieOutput.recordedDuration))
        timeLabel.text = formattedCurrentTime(time)
    }
    
    func stopTimer() {
        updateTimer.invalidate()
        updateTimer = nil
        timeLabel.text = formattedCurrentTime(UInt(0))
    }
    
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
       
        if error != nil {
            print("Error recording movie: \(error!.localizedDescription)")
        }
        else {
            // write video to library
            saveMovieToLibrary(outputFileURL)
            //captureButton.setImage(UIImage(named: "Capture_Butt"), for: .normal)
            stopTimer()
        }

    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
       // captureButton.setImage(UIImage(named: "Capture_Butt1"), for: .normal)
        startTimer()
       
    }
}



