//
//  LocationDetails.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/2/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import Foundation
import CoreLocation

class LocationDetails {
    
    let latitude: String
    let longitude: String
    let speed: Double
    let dateAndTime: String
    
    init(_ latitude: String, _ longitude: String, _ speed: Double, _ dateTime: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.speed = speed
        self.dateAndTime = dateTime
    }
    
    public static var arrayOfData = [LocationDetails]()
    
    func encode() -> [String: Any]{
        var details: [String: Any] = [:]
        
        details[LocationKeys.latitude] = self.latitude
        details[LocationKeys.longitude] = self.longitude
        details[LocationKeys.speed] = self.speed
        details[LocationKeys.dateAndTime] = self.dateAndTime
        
        return details
    }
    
    struct LocationKeys {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let speed = "speed"
        static let dateAndTime = "dateAndTime"

    }
    
}
