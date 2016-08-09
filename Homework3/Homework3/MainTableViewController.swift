//
//  MainTableViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase

class MainTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure we don't show more rows than are needed. In this application we only need four rows for the four static cells on the MainTableView
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedRow = indexPath.row + 1
        
        switch selectedRow {
        case 1:
            // Profile
            performSegueWithIdentifier("showProfileVCSegue", sender: self)
        case 2:
            // Forum
            performSegueWithIdentifier("showForumsVCSegue", sender: self)
            break
        case 3:
            // Inbox
            performSegueWithIdentifier("showInboxVCSegue", sender: self)
            break
        case 4:
            // UserS
            performSegueWithIdentifier("showUsersVCSegue", sender: self)
            break
        default:
            break
        }
        
    }
}
