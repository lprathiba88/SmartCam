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
        
        if UserDetails.tripsArray.count == 0 {
            Firebase.shared.getTripFromFirebase(UserDetails.devideId) { (trips) in
                guard let pastTrips = trips else {
                    print("No trips in Firebase")
                    return
                }
                self.tripsArray = pastTrips
                UserDetails.tripsArray = pastTrips
                DispatchQueue.main.async {
                    self.tripsTableView.reloadData()
                }
            }
        }
        else {
            self.tripsArray = UserDetails.tripsArray
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("tripsArray.count: \(tripsArray.count)")
        return tripsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tripsTableView.dequeueReusableCell(withIdentifier: "tripsCell", for: indexPath) as? TripsTableViewCell else {
            return UITableViewCell()
        }
        
        let tripName = tripsArray[indexPath.row]
                            .tripName
                            .components(separatedBy: "PM")
                            .first!
                            .appending("PM")
        
        cell.tripName.text = tripName
        
        if tripsArray[indexPath.row].videoURL.count > 0 {
            cell.eventIcon.isHidden = false
        }
        else {
            cell.eventIcon.isHidden = true
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

