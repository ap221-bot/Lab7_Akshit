//
//  ViewController.swift
//  Lab7
//
//  Created by user232103 on 11/10/23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //MARK: Neccessary Outlets
    @IBOutlet weak var currentSpdLbl: UILabel!
    @IBOutlet weak var maxSpdLbl: UILabel!
    @IBOutlet weak var averageSpdLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var maxAccLbl: UILabel!
    @IBOutlet weak var topBarLbl: UILabel!
    @IBOutlet weak var bottomBarLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Neccessary variable section
    var locationManager = CLLocationManager()
    var tripStarted = false
    var tripStartTime: Date?
    var totalDistance: CLLocationDistance = 0
    var maxSpeed: CLLocationSpeed = 0
    var maxAcceleration: Double = 0
    var previousLocation: CLLocation?
    var speedList: [CLLocationSpeed] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        bottomBarLbl.backgroundColor = UIColor.gray  //initially making bottom bar gray
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.delegate = self
        mapView.showsUserLocation = true  //initially showing the user location
    }

    //MARK: Start Trip Button
    @IBAction func startTripBtn(_ sender: Any) {
        tripStarted = true
        tripStartTime = Date()
        mapView.showsUserLocation = true
        
        //MARK: checking location service availability
        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
            // Checking for the location allowed by user like always or while in use
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways
            {
                locationManager.startUpdatingLocation()
            }
            else
            {
                //requesting user to give location permission
                locationManager.requestWhenInUseAuthorization()
            }
        }
        else
        {
            print("Location is not on - please first enable the location")
        }
    }

    //MARK: Stop tril button function
    @IBAction func stopTripBtn(_ sender: Any) {
        tripStarted = false
        bottomBarLbl.backgroundColor = UIColor.gray //when we stop trip it should change it to the gray as per requirement
        topBarLbl.backgroundColor = UIColor.white //making topbar white when we clcik in stop trip button
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
    }

    //MARK: Location Manager function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //ensuring the location is valid otherwise exiting the function
        guard let location = locations.last else { return }

        if tripStarted
        {
            //checking the previos location is nil and hadling the case for same
            guard var previousLocation = previousLocation else {
                updateMap(location)
                previousLocation = location
                return
            }
            
            //trip has started so we are making it green as per requirement
            bottomBarLbl.backgroundColor = UIColor.green
            
            //calculating distance and assigning it to label
            let distance = location.distance(from: previousLocation)
            totalDistance += distance
            distanceLbl.text = String(format: "%.2f km", totalDistance / 1000)
            
            //calculating acceleration and assignning it to label
            let acceleration = abs(location.speed - previousLocation.speed) / location.timestamp.timeIntervalSince(previousLocation.timestamp)
            //logic for finding max acceleration
            if acceleration > maxAcceleration
            {
                maxAcceleration = acceleration
                maxAccLbl.text = String(format: "%.2f m/s²", maxAcceleration)
            }

            print(location.speed*3.6)
            //condition for making topbar red
            if location.speed > 115/3.6 {
                topBarLbl.backgroundColor = .red
            }
            
            //condition to make topbar to make white
            if location.speed < 115/3.6
            {
                topBarLbl.backgroundColor = .white
            }

            //handling the list for average speed
            speedList.append(location.speed)
            averageSpdLbl.text = String(format: "%.2f km/h", calculateAverageSpeed() * 3.6)
            updateMap(location)
            previousLocation = location

            //current speed calculation
            currentSpdLbl.text = String(format: "%.2f km/h", location.speed * 3.6)
            
            //logic for calculating max speed
            if location.speed > maxSpeed {
                maxSpeed = location.speed
                maxSpdLbl.text = String(format: "%.2f km/h", maxSpeed * 3.6)
            }
        }
    }

    //MARK: Function to calculate average speed
    func calculateAverageSpeed() -> CLLocationSpeed {
        guard !speedList.isEmpty else { return 0 }
        let sum = speedList.reduce(0, +)
        let averageSpeed = sum / CLLocationSpeed(speedList.count)
        return averageSpeed
    }
    
    //MARK: Function to update the map based on the provided location
    func updateMap(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
    }
    
}

