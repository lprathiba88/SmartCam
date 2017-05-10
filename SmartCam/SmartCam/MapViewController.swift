//
//  MapViewController.swift
//  SmartCam
//
//  Created by Prathiba Lingappan on 5/4/17.
//  Copyright © 2017 Prathiba Lingappan. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps


class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: IBOutlets
    @IBOutlet weak var viewMap: GMSMapView!
    
    // MARK: Properties
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    var origin: String?
    var destination: String?
    
    var mapTasks = MapTasks() // instance needed to access data fetched from MapTasks
    var locationMarker: GMSMarker!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    var markersArray: [GMSMarker] = []
    var waypointsArray: [String] = []
    
    //    var travelMode = TravelModes.driving
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 37.7909131647575, longitude: -122.400455604569, zoom: 8.0)
        viewMap.camera = camera
        viewMap.delegate = self
        
//        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        
        createRoute()
    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if !didFindMyLocation {
//            let myLocation = change?[NSKeyValueChangeKey.newKey] as! CLLocation
//            viewMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
//            viewMap.settings.myLocationButton = true
//            
//            didFindMyLocation = true
//        }
//    }
    
    
    // MARK: Custom method implementation
    
    func createRoute() {
        
        if (self.routePolyline) != nil {
            self.clearRoute()
            //self.waypointsArray.removeAll(keepingCapacity: false)
        }
        
        if let origin = self.origin, let destination = self.destination {
            
            print("origin : \(origin)")
            print("destination : \(destination)")
            //print("waypointsArray: \(waypointsArray)")
            
            self.mapTasks.getDirections(origin, destination: destination, waypoints: waypointsArray,completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    //self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
        else {
            print("Error Passing route details")
        }
    }
    
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.camera(withTarget: mapTasks.originCoordinate, zoom: 9.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = GMSMarker.markerImage(with: UIColor.green)
        originMarker.title = self.mapTasks.originAddress
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.red)
        destinationMarker.title = self.mapTasks.destinationAddress
        
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.components(separatedBy: ",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.components(separatedBy: ",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImage(with: UIColor.purple)
                
                markersArray.append(marker)
            }
        }
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = viewMap
    }
    
    
//    func displayRouteInfo() {
//        lblInfo.text = mapTasks.totalDistance + "\n" + mapTasks.totalDuration
//    }
    
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepingCapacity: false)
        }
    }
    
    func recreateRoute() {
        if (routePolyline) != nil {
            clearRoute()
            
            mapTasks.getDirections(mapTasks.originAddress, destination: mapTasks.destinationAddress, waypoints: waypointsArray, completionHandler: { (status, success) -> Void in
                
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    //self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
    }
    
    
    // MARK: GMSMapViewDelegate method implementation
    
    func mapView(_ mapView: GMSMapView!, didTapAt coordinate: CLLocationCoordinate2D) {
        if (routePolyline) != nil {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            waypointsArray.append(positionString)
            
            recreateRoute()
        }
    }
    
    // MARK: CLLocationManagerDelegate method implementation
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            viewMap.isMyLocationEnabled = true
        }
    }
}

