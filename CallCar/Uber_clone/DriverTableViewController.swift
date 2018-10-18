//
//  DriverTableViewController.swift
//  Uber_clone
//
//  Created by USI on 2018/10/4.
//  Copyright © 2018年 USI. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class DriverTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    let db_reference = Database.database().reference()
    var riderRequest : [DataSnapshot] = []
    
    let locationMgr = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    
    @IBAction func logOutAction(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        } catch  {
            print("Driver Sign Out Error")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        retriveData()
        
        // 需要取得Driver的位置 需要以下設定
        locationMgr.delegate = self
        locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        locationMgr.requestAlwaysAuthorization()
        locationMgr.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        driverLocation = (manager.location?.coordinate)!
    }
    
    func retriveData(){
        db_reference.child("RiderRequest").observe(.childAdded) { (data_snapshot) in
            if let riderRequestDic = data_snapshot.value as? [String:Any] {
                if riderRequestDic["driverLat"] != nil {
                    // 若已有driver的資訊，則代表該rider已被接單，就不顯示在清單上
                }else {
                    if (data_snapshot.value as? [String:Any]) != nil {
                        
                        self.riderRequest.append(data_snapshot)
                        data_snapshot.ref.removeAllObservers()
                        self.tableView.reloadData()
                    }
                    
                }
            }
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return riderRequest.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DriverTableViewCell
        
        let snapShot = riderRequest[indexPath.row]
        if let riderRequestDic = snapShot.value as? [String:Any] {
            if let email = riderRequestDic["email"] as? String , let latitude = riderRequestDic["latitude"] as? Double , let longitude = riderRequestDic["longitude"] as? Double {
                
                // 獲得乘客與司機的距離，要放在cell中的 descriptionLabel 裏
                
                let riderCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                let distance = riderCLLocation.distance(from: driverCLLocation)
                let roundedDistance = round(distance * 100)/100 // 保留兩位小數
                
                if let image = UIImage(named: "user") {
                    let riderDetail = "\(roundedDistance) M Away"
                    cell.configureCell(profileImg: image, email: email, description: riderDetail)
                    
                    
                }
                
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let snapShot = riderRequest[indexPath.row]
        
        
        performSegue(withIdentifier: "pickupSegue", sender: snapShot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "pickupSegue"{
            
            let vc = segue.destination as! PickupViewController
            if let snapShot = sender as? DataSnapshot {
                if let riderRequestDic = snapShot.value as? [String:Any] {
                    
                    if let email = riderRequestDic["email"] as? String , let latitude = riderRequestDic["latitude"] as? Double , let longitude = riderRequestDic["longitude"] as? Double  {
                        
                        vc.riderEmail = email
                        vc.riderLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        vc.driverLocation = driverLocation
                        
                    }
                    
                    
                    
                }
            }
            
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
