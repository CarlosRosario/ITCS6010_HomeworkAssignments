//
//  ForumMessageViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class ForumMessageViewController: UIViewController {

    @IBOutlet weak var forumMessageTextView: UITextView!
    
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        forumMessageTextView.layer.borderWidth = 2.0
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func cancelTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitNewForumMessageTouched(sender: UIButton) {
        
        if forumMessageTextView.text != "" {
        
            // Store message on firebase
            AppDelegate.showLoading("Entering new forum message...", thisView: self.view)
            let currentUser = AppDelegate.currentUser
            let forumReference = self.rootRef.child("Forums").child((currentUser?.firebaseGeneratedId)!).childByAutoId()
            
            let newForum = Forum()
            newForum.forumStarterEmail = currentUser?.emailAddress
            newForum.forumStarterID = currentUser?.firebaseGeneratedId
            newForum.forumStarterName = (currentUser?.firstName)! + " " + (currentUser?.lastName)!
            newForum.forumText = forumMessageTextView.text
            newForum.forumID = forumReference.key
            
            if let imageURL = currentUser?.imageURL {
                newForum.forumStarterImageURL = imageURL
            }
            else {
                newForum.forumStarterImageURL = ""
            }
            
            let forum = [
                "forumStarterEmail": newForum.forumStarterEmail!,
                "forumStarterID": newForum.forumStarterID!,
                "forumStarterName": newForum.forumStarterName!,
                "forumID" : newForum.forumID!,
                "forumText" : newForum.forumText!,
                "forumStarterImageURL": newForum.forumStarterImageURL!
                ] as [String: String]
            
            forumReference.setValue(forum){
                (error, reference) in
                
                if(error != nil){
                    print(error)
                    AppDelegate.hideLoading(self.view)
                    return
                }
                else {
                    AppDelegate.hideLoading(self.view)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        else {
            AppDelegate.showMessage("Oops!", message: "Please enter a forum message...", VC: self)
        }
    }

}
