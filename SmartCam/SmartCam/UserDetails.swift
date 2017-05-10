//
//  UserDetails.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/3/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit

class UserDetails {
    
    static var devideId = UIDevice.current.identifierForVendor?.uuidString
    let tripName: String
    let videoURL: [String]
    //let eventLocation: [String]
    let tripDetails: [LocationDetails]
    
    init(_ tripName: String, _ videoURL: [String], _ details: [LocationDetails]) {
        self.tripName = tripName
        self.videoURL = videoURL
        //self.eventLocation = eventLocation
        self.tripDetails = details
    }
    
    func encode() -> [[String: Any]] {
        return tripDetails.map{ $0.encode() }
    }
    
    struct UserKeys {
        static let deviceID = "deviceID"
        static let tripDetails = "tripDetails"
        static let events = "events"
        //static let eventLocation = "eventLocation"
        static let tripName = "tripName"
    }
    
    static var tripsArray = [UserDetails]()
    
}
