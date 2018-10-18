//
//  RiderViewController.swift
//  Uber_clone
//
//  Created by USI on 2018/10/4.
//  Copyright © 2018年 USI. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase


class RiderViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var call_flag = false
    
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var userLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    var driverLocation:CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    let db_reference:DatabaseReference = Database.database().reference()
    var driverOnTheWay = false
    
    @IBAction func logout_action(_ sender: UIBarButtonItem) {
        do {
            try   Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: {
            })
        } catch  {
            print("User Sign out fail")
        }
        
        
        
    }
    @IBAction func call_action(_ sender: UIButton) {
        
        if !driverOnTheWay {
            if let email = Auth.auth().currentUser?.email {
            
                if !call_flag { // 開始叫車
                    let riderRequestDic : [String:Any] = ["email":email,"latitude":userLocation.latitude,"longitude":userLocation.longitude]
                    //寫入資料庫
                    db_reference.child("RiderRequest").childByAutoId().setValue(riderRequestDic)
                    
                    callMode()
                }else {
                    // observe 為 firebase所提供的監看資料庫的觀察者, 可以設定當達成某些條件，接著去做指定的事，非常的方便 （當新增行為是childAdded,且欄位“email"的值為當下rider的email,則去進行刪除資料的事情）
                    db_reference.child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(DataEventType.childAdded) { (dataSnapShot) in
                        dataSnapShot.ref.removeValue()
                        
                        // 當刪除完資料後，先把觀察者移除，否則會一新增一筆資料，就立刻被刪除
                        self.db_reference.child("RiderRequest").removeAllObservers()
                    }
                    cancelMode()
                }
            }
        }
        
     
    }
    
    func callMode(){
        callButton.setTitle("Cacel Call", for: .normal)
        callButton.backgroundColor = UIColor.red
        callButton.setTitleColor(UIColor.white, for: .normal)
        call_flag = true
        
    }
    
    func cancelMode(){
        callButton.setTitle("Call", for: .normal)
        callButton.backgroundColor = UIColor.green
        callButton.setTitleColor(UIColor.lightGray, for: .normal)
        call_flag = false
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
        // 司機跟乘客有可能不斷改變位置, 所以必須要不斷去更新
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateLocation()
        }
        updateLocation()
    }
    
    func updateLocation(){
        if let email = Auth.auth().currentUser?.email {
            db_reference.child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(DataEventType.childAdded) { (dataSnapShot) in
                self.callMode()
                
                if let driverRequestDic = dataSnapShot.value as? [String:Any],
                    let driverLat = driverRequestDic["driverLat"] as? Double,
                    let driverLon = driverRequestDic["driverLon"] as? Double{
                    
                    self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                    self.driverOnTheWay = true
                    self.displayDriverAndRider()
                    self.db_reference.child("RiderRequest").removeAllObservers()
                    
                }
                
            }
        }
    }
    
    func displayDriverAndRider(){
        let driverCLLocation = CLLocation(latitude:driverLocation.latitude , longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance*100)/100
        callButton.setTitle("Your Driver is \(roundedDistance) KM Away", for: UIControl.State.normal)
        
        // 在地圖上標注RiderAnnotation & DriverAnnotation
        
        mapView.removeAnnotations(mapView.annotations) // 先清除舊的
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your Location"
        mapView.addAnnotation(riderAnnotation)
        
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Driver Location"
        mapView.addAnnotation(driverAnnotation)
        
        // 地圖顯示的範圍設定
        
        let latDelta = abs (driverLocation.latitude - userLocation.latitude)
        let lonDelta = abs (driverLocation.longitude - userLocation.longitude)
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        mapView.setRegion(region, animated: true)
        
    }
    
    // call back function, 當用戶改變地理位置時．會自動呼叫此方法 可取得最新地理位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myCoordinate:CLLocationCoordinate2D = manager.location?.coordinate {
            
            userLocation = myCoordinate
            
            if driverOnTheWay {
                displayDriverAndRider()
            }else {
            
            let region = MKCoordinateRegion(center: myCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.0018, longitudeDelta: 0.0018))
            mapView.setRegion(region, animated: true)
            
            // 添加anotation前, 先刪除之前的anotation
            mapView.removeAnnotations(mapView.annotations)
            
            let myAnnotaion = MKPointAnnotation()
            myAnnotaion.coordinate = myCoordinate
            myAnnotaion.title = "我的位置"
            mapView.addAnnotation(myAnnotaion)
            }
        }
    }
    
}
