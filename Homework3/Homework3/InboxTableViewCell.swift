//
//  InboxTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class InboxTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var blueIconImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    weak var refreshDelegateObject: refreshDelegate?
    
    weak var parent: UITableViewController?

    let rootRef = FIRDatabase.database().reference()
    
    @IBAction func trashTouched(sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Inbox Delete", message: "Do you want to delete this Message?",preferredStyle: UIAlertControllerStyle.Alert)
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: deletion))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in }))
        parent!.presentViewController(refreshAlert, animated: true, completion: nil)
    }
    
    func deletion(alert: UIAlertAction!){
    
        rootRef.child("Messages").child((message?.toID)!).child(message!.messageID!).removeValue()
        self.refreshDelegateObject?.refresh()
    }
    
    var message: Message? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        // reset any existing information
        imageView?.image = nil
        fullNameLabel.text = nil
        messageTextLabel.text = nil
        
        // Set name
        fullNameLabel.text = message?.fromName
        
        // Set messagetext
        messageTextLabel.text = message?.messageText
        
        // Set Image
        if message?.fromImageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (message?.fromImageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
        
        // Show or Hide blue icon
        if message?.hasMessageBeenRead == "0" {
            blueIconImageView.hidden = false
        }
        else if message?.hasMessageBeenRead == "1" {
            blueIconImageView.hidden = true
        }
    }

}
