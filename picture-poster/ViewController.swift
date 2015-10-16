//
//  ViewController.swift
//  picture-poster
//
//  Created by Jonathan Wood on 9/30/15.
//  Copyright © 2015 Jonathan Wood. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
        }
    }

    
    @IBAction func fbBtnPressed() {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) {
            (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("successfully logged in with Facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(authData)")
                        
                        //Creates a new user on first login!
//                        if let provider = authData.provider as? String {
                            let user = ["provider": authData.provider!, "blah": "test"]
                            DataService.ds.createFirebaseUser(authData.uid, user: user)
//                        }
                        
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
                
            }
        }
    }
    
    
    @IBAction func attemptLogin(sender: UIButton!) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
        
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                
                if error != nil {
                    
                    print("Login Failed: \(error)")
                    
                    if error.code == STATUS_INVALID_EMAIL {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            // If there's an error creating the account (a.k.a invalid email)
                            if error != nil {
                                self.showErrorAlert("Error", msg: "Invalid email.")
                            } else {
                                // Otherwise login
                                
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    err, authData in
                                  
                                    let user = ["provider": authData.provider!, "blah": "emailtest"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                    } else if error.code == STATUS_INVALID_PASSWORD {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            // If there's an error creating the account (a.k.a invalid password)
                            if error != nil {
                                self.showErrorAlert("Error", msg: "Invalid password for email.")
                            } else {
                                // Otherwise login
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    err, authData in
                                    
                                    let user = ["provider": authData.provider!, "blah": "emailtest"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                    } else if error.code == STATUS_ACCOUNT_NOTEXIST {
                        DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                            
                            // If there's an error creating the account (a.k.a invalid user)
                            if error != nil {
                                self.showErrorAlert("Error", msg: "Invalid User.")
                            } else {
                                // Otherwise login
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {
                                    err, authData in
                                    
                                    let user = ["provider": authData.provider!, "blah": "emailtest"]
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    
                                })
                                
                                self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                            }
                            
                        })
                    } else {
                        self.showErrorAlert("Login Error", msg: "Please check your username or password.")
                    }
                    
                } else {
                    // If there is no error to begin with, login
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            showErrorAlert("Email and Password Required", msg: "Enter a valid email and password")
                
        }
            
    }
    
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

