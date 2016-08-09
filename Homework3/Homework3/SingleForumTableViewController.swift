//
//  SingleForumTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class SingleForumTableViewController: UITableViewController, refreshDelegate {

    var forum : Forum?
    var forumComments: [ForumComments] = []
    
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure we don't show more rows than are needed. In this application we only need four rows for the four static cells on the MainTableView
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchForumComments()
        
    }
    
    private func fetchForumComments(){
        // Need to fetch relevant forum comments and display them
        self.forumComments.removeAll()
        AppDelegate.showLoading("Loading forum comments...", thisView: self.view)
        rootRef.child("ForumComments").child((forum?.forumID)!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            if(snapshot.value != nil){
                AppDelegate.hideLoading(self.view)
                if(snapshot.value is NSNull){
                    AppDelegate.hideLoading(self.view)
                }
                else {
                    let foundForumComments = snapshot.value! as! [String: AnyObject]
                    
                    for(_, value) in foundForumComments {
                        let valueDictionary = value as! [String: String]
                        
                        
                        let newForumComment = ForumComments()
                        newForumComment.forumCommentKey = valueDictionary["forumCommentKey"]
                        newForumComment.creatorEmail = valueDictionary["creatorEmail"]
                        newForumComment.creatorID = valueDictionary["creatorID"]
                        newForumComment.creatorImageURL = valueDictionary["creatorImageURL"]
                        newForumComment.creatorName = valueDictionary["creatorName"]
                        newForumComment.forumCommentText = valueDictionary["forumCommentText"]
                        newForumComment.auxImageURL = valueDictionary["auxImageURL"]
                        self.forumComments.append(newForumComment)
                    }
                    self.tableView.reloadData()
                    AppDelegate.hideLoading(self.view)
                }
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // I'm basically creating two row static cells + rest dynamic cell with this code
        if(section == 2){
            return forumComments.count
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as? ForumHeaderTableViewCell
            cell?.forum = forum
            return cell!
        }
        else if(indexPath.section == 1){
            let cell = tableView.dequeueReusableCellWithIdentifier("addCommentCell", forIndexPath: indexPath) as? ForumAddCommentTableViewCell
            cell?.forum = forum
            cell?.parent = self
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("commentsCell", forIndexPath: indexPath) as? ForumCommentsTableViewCell
            cell?.forumComment = forumComments[indexPath.row]
            return cell!
        }
    }
    
    @IBAction func backTouched(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func refresh(){
        fetchForumComments()
    }
}
