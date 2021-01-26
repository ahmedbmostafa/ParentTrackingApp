//
//  ViewController.swift
//  ParentTrackingApp
//
//  Created by ahmed mostafa on 9/3/20.
//  Copyright © 2020 ahmed mostafa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class LoginController: UIViewController {
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var emailTxtF: UITextField!
    @IBOutlet weak var passwordTTxtF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if emailTxtF.text != "" && passwordTTxtF.text != "" {
            if let mail = emailTxtF.text {
                if let password = passwordTTxtF.text {
                    Auth.auth().signIn(withEmail: mail, password: password) { (user, err) in
                        
                        if let err = err {
                            self.displayAlert(title: "Error", message: err.localizedDescription)
                            
                        } else if let user = user {
                            let userData = ["provider": user.user.providerID] as [String: Any]
                            self.db.collection("Parent").document("Parent").setData(userData)
                            
                            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                            let MapController = storyBoard.instantiateViewController(withIdentifier: "map") as? MapController
                            MapController?.modalPresentationStyle = .fullScreen
                            self.present(MapController!, animated: true, completion: nil)
                        }
                        
                    }
                }
            }
        } else {
            
            self.displayAlert(title: "Error", message: "Please Enter your Email")

        }
        
    }
    
    @IBAction func signupBtnPressed(_ sender: Any) {
        
        if emailTxtF.text != "" && passwordTTxtF.text != "" {
            if let mail = emailTxtF.text {
                if let password = passwordTTxtF.text {
                    Auth.auth().createUser(withEmail: mail, password: password) { (user, err) in
                        if let err = err {
                            self.displayAlert(title: "Error", message: err.localizedDescription)
                            
                        }else {
                            print("creating user")
                            if let user = user {
                                let userData = ["provider": user.user.providerID] as [String: Any]
                                self.db.collection("Parent").document("Parent").setData(userData)
                                
                                let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
                                let MapController = storyBoard.instantiateViewController(withIdentifier: "map") as? MapController
                                MapController?.modalPresentationStyle = .fullScreen
                                self.present(MapController!, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        } else {
            
                self.displayAlert(title: "Error", message: "Please Enter your Email")

            
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alertControl = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertControl.addAction(alertAction)
        
        self.present(alertControl, animated: true, completion: nil)
    }
}

