//
//  ForumsTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class ForumsTableViewController: UITableViewController, refreshDelegate {

    let rootRef = FIRDatabase.database().reference()
    var forums : [Forum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchForums()
    }
    
    
    private func fetchForums(){
        // Load all messages for this user into tableview data source
        AppDelegate.showLoading("Loading Forum Messages...", thisView: self.view)
        
        // Make sure not to add duplicate messages to the tableview
        self.forums.removeAll()
        rootRef.child("Forums").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
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
                    
                    let forumDictionary = snapshot.value as! [String : AnyObject]
                    
                    for (_, value) in forumDictionary {
                        let individualForumDictionary = value as! [String : AnyObject]
                        
                        for(key, value) in individualForumDictionary {
                            
                            let valueDictionary = value as! [String: String]
                            let newForum = Forum()
                            newForum.forumID = key // valueDictionary["forumID"] would also have worked here just fine
                            newForum.forumText = valueDictionary["forumText"]
                            newForum.forumStarterEmail = valueDictionary["forumStarterEmail"]
                            newForum.forumStarterID = valueDictionary["forumStarterID"]
                            newForum.forumStarterName = valueDictionary["forumStarterName"]
                            
                            if let fromImageURL = valueDictionary["forumStarterImageURL"] as String! {
                                newForum.forumStarterImageURL = fromImageURL
                            }
                            else {
                                newForum.forumStarterImageURL = ""
                            }
                            
                            // Add message to data source so that it shows on tableview
                            self.forums.append(newForum)
                        }
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
        return forums.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("forumcell", forIndexPath: indexPath) as? ForumTableViewCell

        let forum = forums[indexPath.row]
        
        cell!.forum = forum
        cell!.parent = self
        cell!.refreshDelegateObject = self
        
        return cell!
    }
    
    var selectedRow = -1
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        performSegueWithIdentifier("showSingleForumVCSegue", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showSingleForumVCSegue" {
            if let vc = segue.destinationViewController.contentViewController as? SingleForumTableViewController{
                vc.forum = forums[selectedRow]
            }
        }

    }
    
    @IBAction func backTouched(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refresh() {
        fetchForums()
    }

}
