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
    
    func addTripToFirebase(_ key: String, _ data: [[String: Any]]) {
        let ref: FIRDatabaseReference = FIRDatabase.database().reference()
        ref.child("data").child("allTrips").child(key).setValue(data)
    }
    
    func getTripFromFirebase() {
        
    }
}
