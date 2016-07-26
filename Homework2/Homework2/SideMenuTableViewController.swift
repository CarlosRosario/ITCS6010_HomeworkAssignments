//
//  SideMenuTableViewController.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit

class SideMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(64, 0, 0,0) // Make sure the side menu has enough padding on the top to show properly
        self.tableView.backgroundColor = UIColor(red: 0x34, green: 0x49, blue: 0x5e)
        
        // register long click gesture (will be using long click to add/delete items from audio playlist)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(StoriesTableViewController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideMenuTableViewController.reloadTable(_:)), name: "load", object: nil)
    }
    
    func reloadTable(notification: NSNotification){
        tableView.reloadData()
    }

    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                print(indexPath.row)
                
                if(indexPath.section == 0){
                    // don't do anything
                    return
                }
                
                // Remove from playlist
                PlayListData.PlayListDataStruct.playlist.removeAtIndex(indexPath.row)
                showToast("Removed from playlist")
                tableView.reloadData()
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // I'm basically creating a one row static cell + rest dynamic cell with this code
        if(section == 1){
            //print(PlayListData.PlayListDataStruct.playlist.count)
            return PlayListData.PlayListDataStruct.playlist.count
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 0x34, green: 0x49, blue: 0x5e)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("staticCell", forIndexPath: indexPath) as? SideMenuTableViewCell
            cell?.parentTableView = self.tableView
            return cell!
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("audioClipInPlaylistCell", forIndexPath: indexPath) as? SideMenuTableViewCell
            var cellData = (title: "", audioURL: "")
            cellData = PlayListData.PlayListDataStruct.playlist[indexPath.row]
            cell!.data = cellData
            cell?.parentTableView = self.tableView
            return cell!
        }
    }
    
    private func showToast(message: String){
        let toastLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-100, 300, 35))
        toastLabel.backgroundColor = UIColor.blackColor()
        toastLabel.textColor = UIColor.whiteColor()
        toastLabel.textAlignment = NSTextAlignment.Center;
        self.view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animateWithDuration(4.0, delay: 0.1, options: .CurveEaseOut, animations: {
            toastLabel.alpha = 0.0
            }, completion: nil)
    }
    
}
