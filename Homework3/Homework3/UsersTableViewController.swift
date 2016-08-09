//
//  UsersTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD

class UsersTableViewController: UITableViewController {

    let rootRef = FIRDatabase.database().reference()
    var users : [User] = [] // Data source for tableview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure we don't show more rows than are needed.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load all users into tableview data source
        AppDelegate.showLoading("Loading Users...", thisView: self.view)
        // Make sure not to add duplicate users to the tableview
        self.users.removeAll()
        rootRef.child("Users").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.value != nil){
                if(snapshot.value is NSNull){
                    
                }
                else {
                    
                    let userDictionary = snapshot.value as! [String : AnyObject]
                    
                    for (key, value) in userDictionary{
                        let valueDictionary = value as! [String: String]
                        let newUser = User()
                        newUser.firebaseGeneratedId = key
                        newUser.firstName = valueDictionary["firstName"]
                        newUser.lastName = valueDictionary["lastName"]
                        newUser.emailAddress = valueDictionary["emailAddress"]
                        newUser.userName = valueDictionary["userName"]
                        newUser.password = valueDictionary["password"]
                        newUser.imageURL = valueDictionary["imageURL"]
                        
                        // Add user to data source so that it shows on the tableview
                        self.users.append(newUser)
                    }
                    AppDelegate.hideLoading(self.view)
                    
                    // Re-draw tableview
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath) as? UsersTableViewCell
        let currentUser = users[indexPath.row]
                
                var cellData = (imageURL: "", fullName: "")
                
                if let smallProfileImageURL = currentUser.imageURL{
                    cellData.imageURL = smallProfileImageURL
                }
                
                cellData.fullName = currentUser.firstName! + " " + currentUser.lastName!
                cell!.data = cellData
        
        return cell!
    }
    
    var selectedRow = -1 // This variable is used to fetch the appropriate user to pass in prepareforsegue
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        let selectedUser = users[selectedRow]
        
        if(AppDelegate.currentUser?.firebaseGeneratedId == selectedUser.firebaseGeneratedId){
            performSegueWithIdentifier("showProfileVCSegue", sender: self)
        }
        else {
            performSegueWithIdentifier("showUserVCSegue", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showUserVCSegue" {
            if let vc = segue.destinationViewController.contentViewController as? UserViewController{
                vc.selectedUser = users[selectedRow]
            }
        }
        else if segue.identifier == "showProfileVCSegue" {
            
        }
        
    }
    
    @IBAction func addInviteTouched(sender: UIBarButtonItem) {
        performSegueWithIdentifier("showInviteVCSegue", sender: self)
    }
    
    @IBAction func backToMainTouched(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil) // MIGHT need to use unwind segue here but not right now
    }
}

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
}
