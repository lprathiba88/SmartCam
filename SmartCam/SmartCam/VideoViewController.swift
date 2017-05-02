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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var captureButton: UIButton!
    
    let cameraSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    
    var modeData = [String]()
    let movieOutput = AVCaptureMovieFileOutput()
    var updateTimer: Timer!
    var tapTimer: Timer!
    let HDVideoSize = CGSize(width: 1920.0, height: 1080.0)
    var totalRecordingTime: UInt = 0
    var urlBuffer = RingBuffer<URL>(count: 15)
    var count = 0
    
    @IBAction func onCaptureButton(_ sender: AnyObject) {
        if captureButton.isSelected == false {
            captureButton.isSelected = true
            print("Button selected")
        }else {
            captureButton.isSelected = false
            print("Button deselected")
        }
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
        
        // Tap gesture to save incident
        let tapToSaveIncident = UITapGestureRecognizer()
        tapToSaveIncident.addTarget(self, action: #selector(saveIncident))
        tapToSaveIncident.numberOfTapsRequired = 1
        camPreview.addGestureRecognizer(tapToSaveIncident)
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
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let local_video_name = UUID().uuidString + ".mov"
            let path = directory.appendingPathComponent(local_video_name)
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func uniqueURL() -> URL? {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .long
        let date = dateFormatter.string(from: Date())
        
        let path = directory.appendingPathComponent("incident-\(date).mov")
        
        return URL(fileURLWithPath: path)
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
        
        // 5 sec videos
        print("time: \(time)")
        if time == 5 {
            count += 1
            if count%2 == 0 {
                totalRecordingTime += time
                timeLabel.text = formattedCurrentTime(totalRecordingTime)
            }
            if movieOutput.isRecording {
                movieOutput.stopRecording()
            }else{
                movieOutput.startRecording(toOutputFileURL: tempURL(), recordingDelegate: self)
            }
        }
        else {
            timeLabel.text = formattedCurrentTime(time+totalRecordingTime)
        }
    }
    
    func stopTimer() {
        updateTimer.invalidate()
        updateTimer = nil
        timeLabel.text = formattedCurrentTime(UInt(0))
    }
    
    func saveIncident() {
        print("In saveIncident method")
        // start timer for 30 sec after the tap gesture
        if tapTimer != nil {
            tapTimer.invalidate()
        }
        tapTimer = Timer(timeInterval: 30, target: self, selector: #selector(getVideosForIncident), userInfo: nil, repeats: true)
        RunLoop.main.add(tapTimer, forMode: RunLoopMode.commonModes)
    }
    
    func getVideosForIncident() {
        tapTimer.invalidate()
        print("timer stopped afer 30 seconds of tap")
        
        // get 30 seconds of video before and after the tap gesture
        urlBuffer.readIndex = urlBuffer.writeIndex - 12
        var incidentArray: [URL] = []
        var count = 0
        
        while  count < 12 {
            incidentArray.append(urlBuffer.read()!)
            count += 1
        }
        
        // merge videos
        print("number of videos for incident: \(incidentArray.count)")
        mergeVideos(incidentArray)
    }
    
    func mergeVideos(_ incidents: [URL]) {
        print("in merge videos method")
        
        var videoAssets = [AVAsset]()
        
        for url in incidents {
            videoAssets.append(AVAsset(url: url))
        }
        print("items in video assets array: \(videoAssets.count)")
        
        // create AVMutableComposition to hold AVMutableCompositionTrack instances
        let composition = AVMutableComposition()
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        var startTime = kCMTimeZero
        
        for asset in videoAssets {
            
            // Insert video
            let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            do {
                try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: AVMediaTypeVideo)[0], at: startTime)
            }
            catch {
                print("Error creating video track!")
            }
            let instruction = self.videoCompositionInstructionForTrack(track: videoTrack, asset: asset)
            instruction.setOpacity(1.0, at: startTime)
            if asset != videoAssets.last {
                instruction.setOpacity(0.0, at: CMTimeAdd(startTime, asset.duration))
            }
            mainInstruction.layerInstructions.append(instruction)
            startTime = CMTimeAdd(startTime, asset.duration)
        }
        
        let totalDuration = startTime
        
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, totalDuration)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.instructions = [mainInstruction]
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = self.HDVideoSize
        videoComposition.renderScale = 1.0
        
        //Export
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = self.uniqueURL()
        exporter!.outputFileType = AVFileTypeQuickTimeMovie
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.videoComposition = videoComposition
        
        exporter!.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async(execute: { () -> Void in
                self.getPermissionForPhotoLibrary(exporter!)
            })
        })
        
    }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
        if session.status == AVAssetExportSessionStatus.completed {
            let photoLibrary = PHPhotoLibrary.shared()
            photoLibrary.performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: session.outputURL!)
            }) { (success: Bool, error: Error?) -> Void in
                var alertTitle = ""
                var alertMessage = ""
                if success {
                    alertTitle = "Success!"
                    alertMessage = "Incident saved successfully!"
                } else {
                    alertTitle = "Error!"
                    alertMessage = "Failed to save incident!"
                }
                
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
    }
    
    func getPermissionForPhotoLibrary(_ session: AVAssetExportSession)  {
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                print("authorized")
                self.exportDidFinish(session)
            case .denied:
                print("denied")
            case .notDetermined:
                print("not determined")
            case .restricted:
                print("resticted")
            }
        }
    }
    
    func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        var scaleToFitRatio = HDVideoSize.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait {
            //Portrait
            scaleToFitRatio = HDVideoSize.height / assetTrack.naturalSize.width
            
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            let concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: (assetTrack.naturalSize.width * scaleToFitRatio) * 0.60, y: 0))
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        else {
            //Landscape
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            let concat = assetTrack.preferredTransform.concatenating(scaleFactor)
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }

    
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
       
        if error != nil {
            print("Error recording movie: \(error!.localizedDescription)")
        }
        else {
            if captureButton.isSelected == false {
                print("Timer stopped")
                stopTimer()
                captureButton.setImage(UIImage(named: "Camera-50"), for: .normal)
                print("videos in buffer: \(urlBuffer.array)")
            }else{
                print("Recording stopped afer 5 sec")
                urlBuffer.write(outputFileURL)
            }
        }

    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("Timer started")
        captureButton.setImage(UIImage(named: "Camera Filled-50"), for: .normal)
        startTimer()
       
    }
}

//-----------------------------CIRCULAR BUFFER---------------------------------//

public struct RingBuffer<T> {
    fileprivate var array: [T?]
    fileprivate var readIndex = 0
    fileprivate var writeIndex = 0
    
    public init(count: Int) {
        array = [T?](repeating: nil, count: count)
    }
    
    public mutating func write(_ element: T) -> Bool {
        if !isFull {
            array[writeIndex % array.count] = element
            writeIndex += 1
            print("success writing to buffer")
            return true
        } else {
            return false
        }
    }
    
    public mutating func read() -> T? {
        if !isEmpty {
            let element = array[readIndex % array.count]
            readIndex += 1
            print("success reading from buffer")
            return element
        } else {
            return nil
        }
    }
    
    fileprivate var availableSpaceForReading: Int {
        return writeIndex - readIndex
    }
    
    public var isEmpty: Bool {
        return availableSpaceForReading == 0
    }
    
    fileprivate var availableSpaceForWriting: Int {
        return array.count - availableSpaceForReading
    }
    
    public var isFull: Bool {
        return availableSpaceForWriting == 0
    }
}



