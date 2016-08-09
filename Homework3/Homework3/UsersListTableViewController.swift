//
//  UsersListTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class UsersListTableViewController: UITableViewController {

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
                        
                        // Re-draw tableview
                        self.users.append(newUser)
                    }
                    AppDelegate.hideLoading(self.view)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("usercell", forIndexPath: indexPath) as? UserListTableViewCell
        
        let currentUser = users[indexPath.row]
        var cellData = (imageURL: "", fullName: "")
        
        if let smallProfileImageURL = currentUser.imageURL{
            cellData.imageURL = smallProfileImageURL
        }
        
        cellData.fullName = currentUser.firstName! + " " + currentUser.lastName!
        cell!.data = cellData
        
        return cell!
    }
    
    var selectedRow = -1
    var selectedUser : User?
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        selectedUser = users[selectedRow]
        performSegueWithIdentifier("goBackToMessageVCUnwindSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationvc = segue.destinationViewController.contentViewController
        if let messagevc = destinationvc as? MessageViewController{
            if let identifier = segue.identifier{
                switch identifier {
                case "goBackToMessageVCUnwindSegue":
                    messagevc.selectedUser = selectedUser
                default: break
                }
            }
        }

    }
 
}
