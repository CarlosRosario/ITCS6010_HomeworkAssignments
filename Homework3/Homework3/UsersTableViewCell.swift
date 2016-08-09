//
//  UsersTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var smallProfileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var data : (imageURL : String, fullName : String)? {
        didSet{
            updateUI()
        }
    }
    
    private func updateUI(){
        // reset any existing information
        imageView?.image = nil
        fullNameLabel.text = nil
        
        // Set name
        fullNameLabel.text = data?.fullName
        
        // Set Image
        if data?.imageURL == "" {
            let mysteryImage: UIImage = UIImage(named: "mystery-person")!
            smallProfileImageView.image = mysteryImage
        }
        else {
            let imageURL:NSURL? = NSURL(string: (data!.imageURL))
            if let url = imageURL{
                smallProfileImageView.sd_setImageWithURL(url)
            }
        }
    }
}
