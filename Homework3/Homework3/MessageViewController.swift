//
//  MessageViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class MessageViewController: UIViewController {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var fullNameToLabel: UILabel!
    @IBOutlet weak var selectUserToLabel: UILabel!
    @IBOutlet weak var selectUserButton: UIButton!
    var selectedUser: User?
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTextView.layer.borderWidth = 2.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let user = selectedUser {
            fullNameToLabel.hidden = false
            profileImageView.hidden = false
            fullNameLabel.hidden = false
            
            selectUserToLabel.hidden = true
            selectUserButton.hidden = true
            
            // Make the image circular
            profileImageView.layer.borderWidth=1.0
            profileImageView.layer.masksToBounds = false
            profileImageView.layer.borderColor = UIColor.blackColor().CGColor
            profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
            profileImageView.clipsToBounds = true
            
            // Pre-populate profile image if it exists
            if user.imageURL == nil || user.imageURL == "" {
                let mysteryImage: UIImage = UIImage(named: "mystery-person")!
                profileImageView.image = mysteryImage
            }
            else {
                let imageURL:NSURL? = NSURL(string: (user.imageURL)!)
                if let url = imageURL{
                    profileImageView.sd_setImageWithURL(url)
                }
            }
            
            // Pre-populate name and email labels
            fullNameLabel.text = (user.firstName)! + " " + (user.lastName)!
        }
        else {
            fullNameToLabel.hidden = true
            profileImageView.hidden = true
            fullNameLabel.hidden = true
            
            selectUserToLabel.hidden = false
            selectUserButton.hidden = false
        }
        
    }
    
    @IBAction func cancelTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func submitTouched(sender: UIButton) {
        // Store message on firebase
        AppDelegate.showLoading("Sending message...", thisView: self.view)
        let currentUser = AppDelegate.currentUser
        let messageReference = self.rootRef.child("Messages").child((self.selectedUser?.firebaseGeneratedId!)!).childByAutoId()
        
        let newMessage = Message()
        newMessage.messageText = messageTextView.text
        newMessage.fromID = currentUser?.firebaseGeneratedId
        newMessage.fromEmail = currentUser?.emailAddress
        newMessage.toID = selectedUser?.firebaseGeneratedId
        newMessage.toEmail = selectedUser?.emailAddress
        newMessage.messageID = messageReference.key
        newMessage.fromName = (currentUser?.firstName)! + " " + (currentUser?.lastName)!
        newMessage.hasMessageBeenRead = "0" // all messages by default are "not read" to start with
        
        if let imageURL = currentUser?.imageURL {
            newMessage.fromImageURL = imageURL
        }
        else {
            newMessage.fromImageURL = ""
        }
        
        
        
        let message = [
            "messageText": newMessage.messageText!,
            "fromID": newMessage.fromID!,
            "fromEmail": newMessage.fromEmail!,
            "toID" : newMessage.toID!,
            "toEmail" : newMessage.toEmail!,
            "messageID" : newMessage.messageID!,
            "fromImageURL" : newMessage.fromImageURL!,
            "fromName" : newMessage.fromName!,
            "hasMessageBeenRead" : newMessage.hasMessageBeenRead!
            ] as [String: String]
        
        messageReference.setValue(message){
            (error, reference) in
            
            if(error != nil){
                print(error)
                AppDelegate.hideLoading(self.view)
                return
            }
            else {
                print("successfully loaded message")
                AppDelegate.hideLoading(self.view)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    
    
    @IBAction func selectUserTouched(sender: UIButton) {
        performSegueWithIdentifier("showUserListVCSegue", sender: self)
    }
    
    @IBAction func unwindToMessageVC(segue: UIStoryboardSegue){
       // Once we have unwinded to here, we need to hide the select user button and display the selected user and image url
    }
    
    
}
