//
//  ViewController.swift
//  Uber_clone
//
//  Created by USI on 2018/9/28.
//  Copyright © 2018年 USI. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailAddrTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var userModeSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCorner(customView: loginView, radius: 10)
        setCorner(customView: signInBtn, radius: 10)
    }
    
    @IBAction func signInAction(_ sender: UIButton) {
        
        if emailAddrTextField.text != "" && passwordTextField.text != "" {
            
            authService(email: emailAddrTextField.text!, password: passwordTextField.text!)
        }else{
            displayAlert(title: "Sign in Error", message: "please Enter info")
        }
    }
    
    func authService(email:String,password:String){
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                
                guard let nserror = error as? NSError ,let errorString = nserror.userInfo["error_name"] as? String  else {return}
                
                if errorString == "ERROR_USER_NOT_FOUND" {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (result, error) in
                        if error != nil {
                            print(error.debugDescription)
                            self.displayAlert(title: "Create User Error", message:  "User create Error")
                            
                        }else{
                            
                            // Rider = true = isOn ; Driver = false
                            if self.userModeSwitch.isOn {
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "Rider"
                                changeRequest?.commitChanges(completion: nil)
                                
                                self.performSegue(withIdentifier: "riderSegue", sender: self)
                            }else {
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = "Driver"
                                changeRequest?.commitChanges(completion: nil)
                                
                                self.performSegue(withIdentifier: "driverSegue", sender: self)
                            }
                            
                            print("User has been create")
                            
                        }
                    })
                }else{
                    print("other login error  =   " + "\(error.debugDescription)")
                    self.displayAlert(title: "Sign in Error", message:  error!.localizedDescription)
                }
                
            }else {
                
                if result?.user.displayName == "Rider" {
                    self.performSegue(withIdentifier: "riderSegue", sender: self)
                    
                }else if result?.user.displayName == "Driver" {
                    self.performSegue(withIdentifier: "driverSegue", sender: self)
                }
                print("user already sign in")
            }
        }
    }
    
    func displayAlert(title:String,message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func setCorner(customView:UIView , radius:CGFloat){
        customView.layer.cornerRadius = radius
        customView.clipsToBounds = true
        
        setTextField(customTextField: passwordTextField, iconName: "UserIcon")
        setTextField(customTextField: emailAddrTextField, iconName: "PswIcon")
        
    }
    
    func setTextField (customTextField:UITextField,iconName:String){
        
        customTextField.leftViewMode = UITextField.ViewMode.always
        var iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25 , height: 25))
        iconView.contentMode = .scaleAspectFill
        iconView.image = UIImage(named: iconName)
        
        customTextField.leftView = iconView
        
        customTextField.borderStyle = .line
        customTextField.layer.borderWidth = 0.5
        
        
        
        
    }
}

