//
//  Firebase.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/2/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import Foundation
import Firebase

class Firebase {
    
    static var shared: Firebase! = Firebase()
    let ref: FIRDatabaseReference = FIRDatabase.database().reference()
    fileprivate var _refHandle: FIRDatabaseHandle!
    
    func addTripToFirebase(_ tripKey: String, _ data: [String: Any]) {
        // update trips
        ref.child("data").child("allTrips").child(tripKey).setValue(data)
    }
    
    func getTripFromFirebase(_ currentDeviceId: String, _ completion: @escaping([UserDetails]?) -> Void) {
        
        var trips: [UserDetails] = []
        
        _refHandle = ref.child("data").child("allTrips").observe(.childAdded) { (snapshot: FIRDataSnapshot) in
            //A Trip from Firebase
            let trip = snapshot.value as! [String:Any]
            let newDeviceID = trip[UserDetails.UserKeys.deviceID]
            
            guard let deviceIDInString = newDeviceID as? String else {return}
            
            if deviceIDInString ==  currentDeviceId{
                let tripDetails = (trip[UserDetails.UserKeys.tripDetails]) as? [[String: Any]]
                let events = (trip[UserDetails.UserKeys.events]) as? [String] ?? []
                let tripName = snapshot.key
                
                //Creating LocationDetails Instance for each LocationDetails dictionary in newTripDetails array
                var locationArray = [LocationDetails]()
                for i in tripDetails! {
                    guard let latitude = i[LocationDetails.LocationKeys.latitude] as? String else {return}
                    guard let longitude = i[LocationDetails.LocationKeys.longitude] as? String else {return}
                    guard let speed = i[LocationDetails.LocationKeys.speed] as? Double else {return}
                    guard let dateAndTime = i[LocationDetails.LocationKeys.dateAndTime] as? String else {return}
                    
                    let locationDetails = LocationDetails(latitude, longitude, speed, dateAndTime)
                    locationArray.append(locationDetails)
                }
                
                //Creating UserDetails Instance
                let userDetails = UserDetails(tripName, events, locationArray)
                
                trips.append(userDetails)
                
            }
            completion(trips)
        }
    }
}
