//
//  TripDetailsViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/3/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit

class TripDetailsViewController: UIViewController {

    @IBOutlet weak var tripName: UILabel!
    @IBOutlet weak var startLocation: UILabel!
    @IBOutlet weak var stopLocation: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var stopTime: UILabel!
    @IBOutlet weak var averageSpeed: UILabel!
    @IBOutlet weak var firstEvent: UILabel!
    @IBOutlet weak var secondEvent: UILabel!
    
    var tripDetails: UserDetails?
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        guard let details = tripDetails else {return}
        
        self.tripName.text = details.tripName
        self.firstEvent.text = details.videoURL[0]
        
        let locationDetails = details.tripDetails
        
        self.startLocation.text = "\(locationDetails[0].latitude), \(locationDetails[0].longitude)"
        self.stopLocation.text = "\(locationDetails[locationDetails.count - 1].latitude), \(locationDetails[locationDetails.count - 1].longitude)"
        self.startTime.text = locationDetails[0].dateAndTime
        self.stopTime.text = locationDetails[locationDetails.count - 1].dateAndTime
        
        // calculate average speed
        var totalSpeed = 0.0
        for i in locationDetails {
            totalSpeed += i.speed
        }
        self.averageSpeed.text = String(totalSpeed/Double(locationDetails.count))
        
    }


}
