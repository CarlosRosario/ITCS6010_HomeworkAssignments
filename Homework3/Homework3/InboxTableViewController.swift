//
//  InboxTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class InboxTableViewController: UITableViewController, refreshDelegate {

    
    let rootRef = FIRDatabase.database().reference()
    var messages : [Message] = [] // Data source for tableview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure we don't show more rows than are needed.
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchInbox()
    }
    
    private func fetchInbox(){
        // Load all messages for this user into tableview data source
        AppDelegate.showLoading("Loading Inbox Messages...", thisView: self.view)
        
        // Make sure not to add duplicate messages to the tableview
        self.messages.removeAll()
        let currentUser = AppDelegate.currentUser
        rootRef.child("Messages").child((currentUser?.firebaseGeneratedId)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.value != nil){
                AppDelegate.hideLoading(self.view)
                
                // Re-draw tableview
                self.tableView.reloadData()
                if(snapshot.value is NSNull){
                    AppDelegate.hideLoading(self.view)
                    
                    // Re-draw tableview
                    self.tableView.reloadData()
                }
                else {
                    
                    let messageDictionary = snapshot.value as! [String : AnyObject]
                    
                    for (key, value) in messageDictionary{
                        print(key)
                        print(value)
                        
                        let valueDictionary = value as! [String: String]
                        let newMessage = Message()
                        newMessage.messageID = key // valueDictionary["messageID"] would also have worked here just fine
                        newMessage.toID = valueDictionary["toID"]
                        newMessage.toEmail = valueDictionary["toEmail"]
                        newMessage.fromID = valueDictionary["fromID"]
                        newMessage.fromEmail = valueDictionary["fromEmail"]
                        newMessage.fromName = valueDictionary["fromName"]
                        newMessage.hasMessageBeenRead = valueDictionary["hasMessageBeenRead"]
                        newMessage.messageText = valueDictionary["messageText"]
                        
                        if let fromImageURL = valueDictionary["fromImageURL"] as String! {
                            newMessage.fromImageURL = fromImageURL
                        }
                        else {
                            newMessage.fromImageURL = ""
                        }
                        
                        // Add message to data source so that it shows on tableview
                        self.messages.append(newMessage)
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
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("inboxcell", forIndexPath: indexPath) as? InboxTableViewCell
        let message = messages[indexPath.row]

        cell!.message = message
        cell!.parent = self
        cell!.refreshDelegateObject = self
        
        return cell!
    }
    
    var selectedRow = -1
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        let messageSelected = messages[selectedRow]
        
        // update hasMessageBeenRead in Firebase
        rootRef.child("Messages").child((AppDelegate.currentUser?.firebaseGeneratedId)!).child(messageSelected.messageID!).updateChildValues(["hasMessageBeenRead" : "1"]){ (error, reference) in
            
            if(error != nil){
                print(error)
                return
            }
        }

        performSegueWithIdentifier("showMessageDetailSegue", sender: self)
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
        if segue.identifier == "showMessageDetailSegue" {
            if let vc = segue.destinationViewController.contentViewController as? MessageDetailViewController{
                vc.message = messages[selectedRow]
            }
        }
        
    }
    
    @IBAction func backTouched(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addMessageTouched(sender: UIBarButtonItem) {
        
    }
    
    func refresh() {
        fetchInbox()
    }
}
