//
//  TripDetails.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/2/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import Foundation

class TripDetails {
    
    let tripName: String
    let tripDetails: [LocationDetails]
    
    init(_ name: String, _ details: [LocationDetails]) {
        self.tripName = name
        self.tripDetails = details
    }
    
    func encode() -> [[String: Any]] {
        return tripDetails.map{ $0.encode() }
    }
    
}
