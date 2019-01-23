//
//  DriverTableViewController.swift
//  UberClone
//
//  Created by krishna gunjal on 21/01/19.
//  Copyright © 2019 krishna gunjal. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class DriverTableViewController: UITableViewController,CLLocationManagerDelegate {
    var riderReq = [DataSnapshot]()
    let locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    
    @IBAction func logoutTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            if let rideReqDict = snapshot.value as? [String:AnyObject]{
                if let driverLat = rideReqDict["driverLat"] as? Double{
                }
                else{
            self.riderReq.append(snapshot)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
                }
            //If driver moved then it will update the location
            Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { (timer) in
                self.tableView.reloadData()
            })
        }
    }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locationManager.location?.coordinate {
            driverLocation = coordinate
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return riderReq.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let snapshot = riderReq[indexPath.row]
        if let reqDict = snapshot.value as? [String:Any]{
            if let email = reqDict["email"]as? String{
                if let lat = reqDict["lat"]as? Double{
                    if let long = reqDict["long"]as? Double{
                        let driverCLloc = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                        // print("*********\(driverCLloc.coordinate.latitude)*********")
                        let riderCLloc = CLLocation(latitude: lat, longitude: long)
                        let distance = driverCLloc.distance(from: riderCLloc)/1000
                        let roundedDistance = round(distance * 100)/100
                        cell.textLabel?.text = email
                        cell.detailTextLabel?.text = "\(roundedDistance)Km. away"
                    }
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = riderReq[indexPath.row]
        performSegue(withIdentifier: "acceptRequest", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let requestVC = segue.destination as! RequestViewController
        if let snapshot = sender as? DataSnapshot {
            if let reqDict = snapshot.value as? [String:Any]{
                if let email = reqDict["email"]as? String{
                    if let lat = reqDict["lat"]as? Double{
                        if let long = reqDict["long"]as? Double{
                            requestVC.email = email
                            let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            requestVC.requestLocation = location
                            requestVC.driverLocation = driverLocation
                        }
                    }
                }
            }
        }
        
    }
    
    
    
}
