//
//  TripsViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/3/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit

class TripsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tripsTableView: UITableView!
    
    var tripsArray: [UserDetails] = []
    var selectedIndexPath: IndexPath?
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Firebase.shared.getTripFromFirebase(UserDetails.devideId) { (trips) in
            guard let pastTrips = trips else {
                print("No trips in Firebase")
                return
            }
            self.tripsArray = pastTrips
            DispatchQueue.main.async {
                self.tripsTableView.reloadData()
            }
//            print("tripsArray count: \(self.tripsArray.count)")
//            print("1st trip location details array count: \(self.tripsArray[0].tripDetails.count)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tripsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tripsTableView.dequeueReusableCell(withIdentifier: "tripsCell", for: indexPath) as? TripsTableViewCell else {
            return UITableViewCell()
        }
        
        var tripName = tripsArray[indexPath.row].tripName
        // ToDo - manipulate string to get only date and time for trip name
        cell.tripName.text = tripName
        //cell.numberLabel.text = String(indexPath.row + 1)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "toTripDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TripDetailsViewController {
            if let selectedIndexPath = selectedIndexPath {
                destination.tripDetails = tripsArray[selectedIndexPath.row]
            }
        }
    }
   
}

