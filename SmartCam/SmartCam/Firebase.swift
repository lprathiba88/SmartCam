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
    
    func addTripToFirebase(_ tripKey: String, _ data: [String: Any]) {
        // update trips
        ref.child("data").child("allTrips").child(tripKey).setValue(data)
    }
    
    func getTripFromFirebase() {
        
    }
}
