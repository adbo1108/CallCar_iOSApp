//
//  PickupViewController.swift
//  Uber_clone
//
//  Created by USI on 2018/10/17.
//  Copyright © 2018年 USI. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class PickupViewController: UIViewController,MKMapViewDelegate{
    
    var riderEmail = ""
    var riderLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()
    let reference = Database.database().reference()
    
    @IBOutlet weak var mapView: MKMapView!
    
    // 司機接單
    @IBAction func pickUp_Action(_ sender: UIButton) {
        
        // 觀察者為single event
        reference.child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observeSingleEvent(of: DataEventType.childAdded) { (dataSnapShot) in
            // 在資料庫上即時新增司機欄位
            dataSnapShot.ref.updateChildValues(["driverLat" : self.driverLocation.latitude,"driverLon":self.driverLocation.longitude])
            
            let riderCLLocation = CLLocation(latitude: self.riderLocation.latitude, longitude: self.riderLocation.longitude)
            
            CLGeocoder().reverseGeocodeLocation(riderCLLocation, completionHandler: { (clPlaceMark_Array, error) in
                
                if error != nil {
                    print(error.debugDescription)
                }else {
                    
                    if let placemarks = clPlaceMark_Array {
                        if placemarks.count > 0 {
                            let placeMark = MKPlacemark(placemark: placemarks[0])
                            let mapItem = MKMapItem(placemark: placeMark)
                            mapItem.name = self.riderEmail
                            
                            // 開啟導航
                            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
                        }
                    }
                    
                }
            })
            
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018)
        let region = MKCoordinateRegion(center: riderLocation, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = riderLocation
        annotation.title = riderEmail
        mapView.addAnnotation(annotation)
    }
    
    
    
}
