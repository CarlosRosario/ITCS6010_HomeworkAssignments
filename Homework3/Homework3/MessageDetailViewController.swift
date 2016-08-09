//
//  MessageDetailViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class MessageDetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageTextTextView: UITextView!
    
    let rootRef = FIRDatabase.database().reference()
    
    var message: Message?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make the image circular
        profileImageView.layer.borderWidth=1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.blackColor().CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        
        // Set profile image
        if let fromImageURL = message?.fromImageURL {
            let imageURL:NSURL? = NSURL(string: (fromImageURL))
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
        
        // Set full name
        fullNameLabel.text = message?.fromName
        
        // Set message text
        messageTextTextView.text = message?.messageText
    }
    
    @IBAction func backTouched(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    let userToReplyTo = User()
    @IBAction func replyTouched(sender: UIBarButtonItem) {
        
        let uniqueKeyForThisUser = message?.fromID
        // Fetch selected user from firebase, created user object, pass it to MessageViewController
        rootRef.child("Users").child((uniqueKeyForThisUser)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.value != nil){
                if(snapshot.value is NSNull){
                    
                }
                else {
                    let foundUser = snapshot.value! as! [String: String]
                    
                    self.userToReplyTo.firebaseGeneratedId = uniqueKeyForThisUser
                    self.userToReplyTo.firstName = foundUser["firstName"]
                    self.userToReplyTo.lastName = foundUser["lastName"]
                    self.userToReplyTo.emailAddress = foundUser["emailAddress"]
                    self.userToReplyTo.userName = foundUser["userName"]
                    self.userToReplyTo.password = foundUser["password"]
                    self.userToReplyTo.imageURL = foundUser["imageURL"]
                    
                    self.performSegueWithIdentifier("showMessageVCSegue", sender: self)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
        if segue.identifier == "showMessageVCSegue" {
            if let vc = segue.destinationViewController.contentViewController as? MessageViewController{
                vc.selectedUser = userToReplyTo
            }
        }
    }
}
