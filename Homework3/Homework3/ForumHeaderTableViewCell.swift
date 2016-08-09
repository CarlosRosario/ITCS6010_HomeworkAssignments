//
//  ForumHeaderTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage

class ForumHeaderTableViewCell: UITableViewCell {


    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var forumMessageTextView: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var forum : Forum? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        profileImageView.image = nil
        forumMessageTextView.text = nil
        
        // Set name
        fullNameLabel.text = forum?.forumStarterName
        
        // Set Message Text
        forumMessageTextView.text = forum?.forumText
        
        // Set Image
        if forum?.forumStarterImageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (forum?.forumStarterImageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
    }
}
