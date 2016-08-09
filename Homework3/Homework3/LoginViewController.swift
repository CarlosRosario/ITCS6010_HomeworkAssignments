//
//  LoginViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let rootRef = FIRDatabase.database().reference()
    
    // Lockout boolean variables - ugh.
    var didAuthStateChange = false
    var didAutoSegueOccur = false
    var wasLoginButtonTouched = false
    var cameFromUnwindSegue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Check if there is a currently signed in users
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            
            // Prevent this listener from being called twice in immediate succession. I don't think removing the listener is a good strategy either
            if(self.didAuthStateChange){
                return
            }
            else {
                self.didAuthStateChange = true
            }
            
            if(self.wasLoginButtonTouched || self.cameFromUnwindSegue){
                return
            }
            
            if let authUser = user {
                
                AppDelegate.showLoading("Wait just a sec whiile we log you in :)", thisView: self.view)
                
                // User is signed in, lets go ahead and segue to the main view controller
                if(!self.didAutoSegueOccur){
                    
                    let uniqueKeyForThisUser = authUser.uid
                    self.rootRef.child("Users").child(uniqueKeyForThisUser).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        
                        if(snapshot.value != nil){
                            if(snapshot.value is NSNull){
                                
                            }
                            else {
                                let foundUser = snapshot.value! as! [String: String] // User that firebase located by "uniqueKeyForThisUser". The type of this dictionary might change as i keep working on this assignment.
                                
                                // Lets create a user object for this user to use throughout the application
                                let newUser = User()
                                newUser.firebaseGeneratedId = uniqueKeyForThisUser
                                newUser.firstName = foundUser["firstName"]
                                newUser.lastName = foundUser["lastName"]
                                newUser.emailAddress = foundUser["emailAddress"]
                                newUser.userName = foundUser["userName"]
                                newUser.password = foundUser["password"]
                                newUser.imageURL = foundUser["imageURL"]
                                AppDelegate.currentUser = newUser
                                
                                AppDelegate.hideLoading(self.view)
                                self.didAutoSegueOccur = true
                                self.performSegueWithIdentifier("ShowMainTableVCSegue", sender: self)
                            }
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue){
        cameFromUnwindSegue = true
        try! FIRAuth.auth()!.signOut()
        AppDelegate.currentUser = nil
    }
    
    @IBAction func loginTouched(sender: UIButton) {
    
        wasLoginButtonTouched = true
        
        let email : String = emailTextField.text!
        let password : String = passwordTextField.text!
        
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) -> Void in
            
            if(error == nil){
                
                AppDelegate.showLoading("Logging you in", thisView: self.view)
                
                // User successfully signed in
                let uniqueKeyForThisUser = user?.uid
                self.rootRef.child("Users").child(uniqueKeyForThisUser!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    
                    if(snapshot.value != nil){
                        if(snapshot.value is NSNull){
                        }
                        else {
        
                            let foundUser = snapshot.value! as! [String: String] // User that firebase located by "uniqueKeyForThisUser". The type of this dictionary might change as i keep working on this assignment.
                            
                            // Lets create a user object for this user to use throughout the application
                            let newUser = User()
                            newUser.firebaseGeneratedId = uniqueKeyForThisUser
                            newUser.firstName = foundUser["firstName"]
                            newUser.lastName = foundUser["lastName"]
                            newUser.emailAddress = foundUser["emailAddress"]
                            newUser.userName = foundUser["userName"]
                            newUser.password = foundUser["password"]
                            newUser.imageURL = foundUser["imageURL"]
                            AppDelegate.currentUser = newUser
                            
                            AppDelegate.hideLoading(self.view)
                            self.performSegueWithIdentifier("ShowMainTableVCSegue", sender: self)
                        }
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
            else {
                // Could not sign User in
                print(error?.localizedDescription)
                AppDelegate.showMessage("Login failed", message: "Could not login this user. Please try again", VC: self)
            }
        }
    }
}
