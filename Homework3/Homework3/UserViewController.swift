//
//  UserViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage

class UserViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var selectedUser: User?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make the image circular
        profileImageView.layer.borderWidth=1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.blackColor().CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        // Pre-populate profile image if it exists
        if selectedUser?.imageURL == nil || selectedUser?.imageURL == "" {
            let mysteryImage: UIImage = UIImage(named: "mystery-person")!
            profileImageView.image = mysteryImage
        }
        else {
            let imageURL:NSURL? = NSURL(string: (selectedUser?.imageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
        
        // Pre-populate name and email labels
        fullNameLabel.text = (selectedUser?.firstName)! + " " + (selectedUser?.lastName)!
        emailLabel.text = selectedUser?.emailAddress
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func kiteTouched(sender: UIBarButtonItem) {
        performSegueWithIdentifier("showMessageVCSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessageVCSegue" {
            if let vc = segue.destinationViewController.contentViewController as? MessageViewController{
                vc.selectedUser = selectedUser
            }
        }
    }
    
    
    @IBAction func goBackToUsersTableTouched(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
