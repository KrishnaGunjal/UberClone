//
//  ViewController.swift
//  UberClone
//
//  Created by krishna gunjal on 21/01/19.
//  Copyright © 2019 krishna gunjal. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var riderDriverSwitch: UISwitch!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    var signUpMode = true
    @IBAction func topClicked(_ sender: Any) {
        if txtEmail.text == "" || txtPassword.text == "" {
            displayAlert(title: "Missing Information", message: "You must provide both Email and Password")
        }
        else{
            if let email = txtEmail.text{
                if let password = txtPassword.text{
                    if signUpMode{
                        //sign Up
                        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                            }
                            else{
                                print("Sign Up success")
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        }
                    }
                    else{
                        //log in
                        Auth.auth().signIn(withEmail: email, password: password) { (data, error) in
                            if error != nil{
                                self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                            }
                            else{
                                print("Sign In success")
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayAlert(title: String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func bottomClicked(_ sender: Any) {
        if signUpMode {
            topButton.setTitle("Log In", for: .normal)
            bottomButton.setTitle("Switch to Sign Up", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            riderDriverSwitch.isHidden = true
            signUpMode = false
        }
        else{
            topButton.setTitle("Sign In", for: .normal)
            bottomButton.setTitle("Switch to Log In", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            riderDriverSwitch.isHidden = false
            signUpMode = true
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    
}

