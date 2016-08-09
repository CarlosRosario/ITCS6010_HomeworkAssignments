//
//  ForumTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class ForumTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var forumMessageTextView: UITextView!
    @IBOutlet weak var deleteForumMessageButton: UIButton!

    weak var refreshDelegateObject: refreshDelegate?
    weak var parent: UITableViewController?
    
    let rootRef = FIRDatabase.database().reference()
    
    @IBAction func deleteForumMessageTouched(sender: UIButton) {
        
        let refreshAlert = UIAlertController(title: "Forum Delete", message: "Do you want to delete this Message?",preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: deletion))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in }))
        parent!.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func deletion(alert: UIAlertAction!){
        rootRef.child("Forums").child((forum?.forumStarterID)!).child(forum!.forumID!).removeValue()
        self.refreshDelegateObject?.refresh()
    }
    
    var forum: Forum? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        // reset any existing information
        profileImageView?.image = nil
        fullNameLabel.text = nil
        forumMessageTextView.text = nil
        
        // Set name
        fullNameLabel.text = forum?.forumStarterName
        
        // Set messagetext
        forumMessageTextView.text = forum?.forumText
        
        // Set Image
        if forum?.forumStarterImageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (forum?.forumStarterImageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
        
        if AppDelegate.currentUser?.firebaseGeneratedId == forum?.forumStarterID {
            deleteForumMessageButton.hidden = false
        }
        else {
            deleteForumMessageButton.hidden = true
        }
    }
}
