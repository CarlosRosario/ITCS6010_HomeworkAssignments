//
//  ForumCommentsTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class ForumCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var forumCommentTextView: UITextView!
    @IBOutlet weak var deleteTouched: UIButton!
    @IBOutlet weak var auxImageView: UIImageView!
    
    weak var refreshDelegateObject: refreshDelegate?
    
    let rootRef = FIRDatabase.database().reference()
    
    var forumComment: ForumComments? {
        didSet {
            updateUI()
        }
    }
    
    var forum: Forum?
    
    private func updateUI(){
        
        profileImageView.image = nil
        fullNameLabel.text = nil
        forumCommentTextView.text = nil
        auxImageView.image = nil
        
        // Set name
        fullNameLabel.text = forumComment?.creatorName
        
        // Set Message Text
        forumCommentTextView.text = forumComment?.forumCommentText
        
        // Set Profile Image
        if forumComment?.creatorImageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (forumComment?.creatorImageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
        
        // Set Aux Image
        if forumComment?.auxImageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (forumComment?.auxImageURL)!)
            if let url = imageURL{
                auxImageView.sd_setImageWithURL(url)
            }
        }
        
        // Show the trashcan button for "this" users forum comments only
        let currentUser = AppDelegate.currentUser
        if currentUser?.firebaseGeneratedId == forumComment?.creatorID {
            deleteTouched.hidden = false
        }
        else {
            deleteTouched.hidden = true
        }
    }
    
    // TODO
    @IBAction func deleteTouchedAction(sender: UIButton) {
        rootRef.child("ForumComments").child(forum!.forumID!).child(forumComment!.forumCommentKey!).removeValue()
        refreshDelegateObject?.refresh()
    }
    
}
