//
//  ViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 4/24/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var videoFileOutput = AVCaptureMovieFileOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.layer.addSublayer(previewLayer)
        view.addSubview(tapGesture)
        
        cameraSession.startRunning()
    }
    
    lazy var tapGesture: UIView = {
        let tapGesture = UIView()
        
        let xAxis: CGFloat = 70
        let yAxis: CGFloat = 400
        let bWidth: CGFloat = 100
        let bHeight: CGFloat = 20
        
        tapGesture.frame = CGRect(x: xAxis, y: yAxis, width: bWidth, height: bHeight)
        tapGesture.backgroundColor = UIColor.red
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(tap))
        tapGesture.addGestureRecognizer(tapRecognizer)
        
        //button.addTarget(self, action: #selector(startRecording), for: UIControlEvents.touchUpInside)
        
        return tapGesture
        
    }()
    
    lazy var cameraSession: AVCaptureSession = {
        let s = AVCaptureSession()
        s.sessionPreset = AVCaptureSessionPresetLow
        return s
    }()
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview =  AVCaptureVideoPreviewLayer(session: self.cameraSession)
        preview?.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        preview?.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        preview?.videoGravity = AVLayerVideoGravityResize
        return preview!
    }()
    
    func tap(sender: Any) {
        
        let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self as AVCaptureFileOutputRecordingDelegate
        self.cameraSession.addOutput(videoFileOutput)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: [])
            
            // Print the urls of the files contained in the documents directory
            print(directoryContents[0])
            
            for file in directoryContents {
                print(file)
            }
        } catch {
            print("Could not search for urls of files in documents directory: \(error)")
        }
        
        self.videoFileOutput.stopRecording()
        let local_video_name = UUID().uuidString + ".mp4"
        let filePath = documentsURL.appendingPathComponent(local_video_name)
        
        videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: recordingDelegate)
        
    }
    
    func setupCameraSession() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) as AVCaptureDevice
        
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            cameraSession.beginConfiguration()
            
            if (cameraSession.canAddInput(deviceInput) == true) {
                cameraSession.addInput(deviceInput)
            }
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if (cameraSession.canAddOutput(dataOutput) == true) {
                cameraSession.addOutput(dataOutput)
            }
            
            cameraSession.commitConfiguration()
            
            let queue = DispatchQueue(label: "com.invasivecode.videoQueue")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
            
        }
        catch let error as NSError {
            NSLog("\(error), \(error.localizedDescription)")
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you collect each frame and process it
        
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        // Here you can count how many frames are dopped
    }
    
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
}



