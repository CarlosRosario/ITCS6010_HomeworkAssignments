//
//  StoriesTableViewController.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class StoriesTableViewController: UITableViewController {

    var storiesFeed: StoriesFeed?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register long click gesture (will be using long click to add/delete items from audio playlist)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(StoriesTableViewController.longPress(_:)))
        self.view.addGestureRecognizer(longPressRecognizer)
        
    }
    
    func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = longPressGestureRecognizer.locationInView(self.view)
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                print(indexPath.row)
                var playlistData = (title: "", audioURL: "")
                playlistData.title = (storiesFeed?.items[indexPath.row].title)!
                playlistData.audioURL = storiesFeed!.items[indexPath.row].audioURL
                
                // Add to playlist
                PlayListData.PlayListDataStruct.playlist.append(playlistData)
                NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
                showToast("Added to playlist")
            }
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(storiesFeed != nil){
            return (storiesFeed?.items.count)!
        }
        else {
            return 0
        }

    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let StoryItem = storiesFeed?.items[row]
        
        // If the thumbURL actually exists (It seems to show rarely in the JSONS i have examined) then we should use
        // the tableviewcell that has the imageview in it. Otherwise just use the regular tableviewcell.
        if let thumbURL = StoryItem?.thumbnailURL{
            let cell = tableView.dequeueReusableCellWithIdentifier("imageStoryViewCell", forIndexPath: indexPath)
            
            if let imageStoryCell = cell as? ImageStoryTableViewCell{
                
                var cellData = (imageURL: "", title: "", teaser: "", date: "", audioURL: "")
                
                if let storyTitle = StoryItem?.title{
                    cellData.title = storyTitle
                } else {
                    cellData.title = "No Title Found"
                }
                
                if let storyTeaser = StoryItem?.teaser {
                    cellData.teaser = storyTeaser
                } else {
                    cellData.teaser = "No Teaser Found"
                }
                
                if let storyDate = StoryItem?.storyDate{
                    cellData.date = storyDate
                } else {
                    cellData.date = "No Date Found"
                }
                
                if let storyAudioURL = StoryItem?.audioURL {
                    cellData.audioURL = storyAudioURL
                } else {
                    cellData.audioURL = ""
                }
                
                cellData.imageURL = thumbURL
                
                imageStoryCell.data = cellData
            }
            return cell

        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("noImageStoryCell", forIndexPath: indexPath)
            
            if let noImageStoryCell = cell as? NoImageStoryTableViewCell{
                
                var cellData = (title: "", teaser: "", date: "", audioURL: "")
                
                if let storyTitle = StoryItem?.title{
                    cellData.title = storyTitle
                } else {
                    cellData.title = "No Title Found"
                }
                
                if let storyTeaser = StoryItem?.teaser {
                    cellData.teaser = storyTeaser
                } else {
                    cellData.teaser = "No Teaser Found"
                }
                
                if let storyDate = StoryItem?.storyDate{
                    cellData.date = storyDate
                } else {
                    cellData.date = "No Date Found"
                }
                
                if let storyAudioURL = StoryItem?.audioURL {
                    cellData.audioURL = storyAudioURL
                } else {
                    cellData.audioURL = ""
                }
                noImageStoryCell.data = cellData
            }
            return cell
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
    
    @IBAction func revealSideMenu(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
}
