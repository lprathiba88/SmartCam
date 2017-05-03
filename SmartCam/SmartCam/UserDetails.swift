//
//  UserDetails.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/3/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import Foundation

class UserDetails {
    
    let devideId: String
    let tripName: String
    let videoURL: [String]
    let tripDetails: [LocationDetails]
    
    init(_ tripName: String, _ videoURL: [String], _ details: [LocationDetails]) {
        self.tripName = tripName
        self.videoURL = videoURL
        self.tripDetails = details
        self.devideId = "device_1"
    }
    
    func createDictionaryOfEventsForTrip() -> [String: [String]]{
        var eventsDictionary: [String: [String]] = [:]        
        eventsDictionary[tripName] = videoURL
        
        return eventsDictionary
    }
    
    func encode() -> [[String: Any]] {
        return tripDetails.map{ $0.encode() }
    }
    
    struct UserKeys {
        static let deviceID = "deviceID"
        static let tripDetails = "tripDetails"
        static let events = "events"
    }
    
    
}
