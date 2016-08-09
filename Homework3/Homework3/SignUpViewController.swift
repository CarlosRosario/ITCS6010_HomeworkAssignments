//
//  SignUpViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitTouched(sender: UIButton) {
        
        // First make sure all fields have been entered
        if firstNameTextField.text == nil || lastNameTextField.text == nil || emailTextField.text == nil || passwordTextField.text == nil || confirmPasswordTextField.text == nil {
            AppDelegate.showMessage("Error", message: "Please fill out all fields before attempting to sign up.", VC: self)
            return
            
        // Now make sure that passwords match
        } else if passwordTextField.text != confirmPasswordTextField.text {
            AppDelegate.showMessage("Error confirming password", message: "Please make sure to type in the same password in both password and confirm password fields", VC: self)
            return
        }
        else {
            
            let email = emailTextField.text!
            let password  = passwordTextField.text!
            
            // Show spinner
            AppDelegate.showLoading("Signing you up...", thisView: self.view)
            FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) -> Void in
                if(error == nil){
                    
                    // Add a new user to firebase database
                    let newUser = User()
                    let userReference = self.rootRef.child("Users").child((user?.uid)!)
                    newUser.firebaseGeneratedId = user?.uid
                    newUser.firstName = self.firstNameTextField.text!
                    newUser.lastName = self.lastNameTextField.text!
                    newUser.emailAddress = self.emailTextField.text!
                    newUser.password = self.passwordTextField.text!
                    newUser.imageURL = ""
                    AppDelegate.currentUser = newUser
                    
                    let values = [
                        "firstName": (AppDelegate.currentUser?.firstName)!,
                        "lastName": (AppDelegate.currentUser?.lastName)!,
                        "emailAddress": (AppDelegate.currentUser?.emailAddress)!,
                        "userName" : (AppDelegate.currentUser?.emailAddress)!,
                        "password" : (AppDelegate.currentUser?.password)!
                    ] as [String: String]
                    
                    userReference.updateChildValues(values){
                        (error, reference) in
                        
                        if(error != nil){
                            print(error)
                            return
                        }
                        else {
                            // Stop spinner
                            AppDelegate.hideLoading(self.view)
                            self.performSegueWithIdentifier("ShowMainTableVCSegue", sender: self)
                        }
                    }
                }
                else if (error?.userInfo["error_name"])! as! String == "ERROR_EMAIL_ALREADY_IN_USE"{
                    AppDelegate.hideLoading(self.view)
                    AppDelegate.showMessage("Error creating account", message: "This email is already used", VC: self)
                }
                else {
                    AppDelegate.hideLoading(self.view)
                    AppDelegate.showMessage("Error signing up", message: "There was an error signing you up. Please make sure all fields are populated and try again.", VC: self)
                }
            }
        }
    }
}
