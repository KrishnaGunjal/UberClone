//
//  RiderViewController.swift
//  UberClone
//
//  Created by krishna gunjal on 21/01/19.
//  Copyright © 2019 krishna gunjal. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController,CLLocationManagerDelegate {
    var locationMager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
    
    
    var uberCalled = false
    @IBOutlet weak var callAnUberTapped: UIButton!
    
    @IBAction func callAnUberButton(_ sender: Any) {
        if driverOnTheWay == false {
            
            
            if let email = Auth.auth().currentUser?.email {
                if uberCalled {
                    uberCalled = false
                    callAnUberTapped.setTitle("Call an Uber", for: .normal)
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                        snapshot.ref.removeValue()
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    }
                }
                else{
                    let rideReqDict : [String:Any] = ["email":email, "lat":userLocation.latitude, "long":userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideReqDict)
                    uberCalled = true
                    callAnUberTapped.setTitle("Cancel Uber", for: .normal)
                    
                }
            }
        }
    }
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func logOutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationMager.delegate = self
        locationMager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationMager.startUpdatingLocation()
        locationMager.requestWhenInUseAuthorization()
        self.locationMager.startUpdatingLocation()
        self.map.reloadInputViews()
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                self.uberCalled = true
                self.callAnUberTapped.setTitle("Cancel Uber", for: .normal)
                
                Database.database().reference().child("RideRequests").removeAllObservers()
                
                if let rideReqDict = snapshot.value as? [String:AnyObject]{
                    if let driverLat = rideReqDict["driverLat"] as? Double{
                        if let driverLong = rideReqDict["driverong"] as? Double{
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLong)
                            self.driverOnTheWay = true
                            self.displayDriverANdRider()
                        }
                    }
                }
            }
        }
    }
    
    func displayDriverANdRider(){
        let driverLoc = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distance = driverLoc.distance(from: riderLoc)/1000
        let roundedDistance = round(distance * 100)/100
        callAnUberTapped.setTitle("Your Driver is \(roundedDistance)Km. away", for: .normal)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationMager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.userLocation = center
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            map.addAnnotation(annotation)
            self.map.showsUserLocation = true
            map.reloadInputViews()
        }
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
