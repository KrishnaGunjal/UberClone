//
//  RequestViewController.swift
//  UberClone
//
//  Created by krishna gunjal on 21/01/19.
//  Copyright © 2019 krishna gunjal. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class RequestViewController: UIViewController {
    var email : String!
    var requestLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.title = email
        annotation.coordinate = requestLocation
        map.addAnnotation(annotation)
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        //Updating Ride Request
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude,"driverLong":self.driverLocation.longitude])
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        //Give Directions
        let reqLoc = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
        CLGeocoder().reverseGeocodeLocation(reqLoc) { (placemarks, error) in
            if let placemarks = placemarks{
                if placemarks.count > 0{
                    let placemark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = self.email
                    let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
        
    }
    
}
