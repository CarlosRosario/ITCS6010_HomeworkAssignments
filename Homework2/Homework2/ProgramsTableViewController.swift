//
//  ProgramsTableViewController.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/23/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class ProgramsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {

    var selectedRow = -1
    var initialDataSet = false
    var programDataURL: NSURL?{
        didSet{
            if view.window != nil && !initialDataSet{
                initialDataSet = true
                fetchData()
            }
        }
    }
    
    // Holds data for initial tableview
    var programFeed: ProgramsFeed?{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    // Holds data for second tableview (stories tableview)
    var storyFeed: StoriesFeed? = nil
    
    // Data Loading Elements
    let loadingView = UIView()
    let loadingSpinner = UIActivityIndicatorView()
    let loadingLabel = UILabel()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !initialDataSet{
            fetchData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load initial program data
        programDataURL = convertStringToNSURL(NPR_API.PROGRAMS_API)
        
        // Make the app a little more pretty
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red: 0xff, green: 0x44, blue: 0x44)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(programFeed != nil){
            return (programFeed?.items.count)!
        }
        else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("programCell", forIndexPath: indexPath)
        cell.textLabel?.text = programFeed?.items[indexPath.row].title
        return cell
    }

    // This will bring up the popover when clicking on the "i" accessory in each row
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        //print("accessory " + String(indexPath.row))
        
        let popVC = storyboard?.instantiateViewControllerWithIdentifier("additionalInfoPopOver") as! PopViewController
        popVC.navTitle = programFeed?.items[indexPath.row].title
        popVC.additionalInformation = programFeed?.items[indexPath.row].additionalInfo
        popVC.preferredContentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: 300)
        let navController = UINavigationController(rootViewController: popVC)
        navController.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = navController.popoverPresentationController
        popover?.delegate = self
        
        popover?.sourceView = tableView
        popover?.sourceRect = indexPath.accessibilityFrame
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("row clicked " + String(indexPath.row))
        
        selectedRow = indexPath.row
        
        // Call API
        let selectedProgramId = programFeed?.items[selectedRow].id
        let storyAPIURL = NPR_API.generateStoryAPIById(selectedProgramId!)
        let storyAPIURLNSURL = convertStringToNSURL(storyAPIURL)
        let request = NSURLRequest(URL: storyAPIURLNSURL!)
        
        self.setLoadingScreen()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error == nil && data != nil {
                let storyFeed = StoriesFeed(data: data!, sourceURL: storyAPIURLNSURL!)
                self.storyFeed = storyFeed
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    
                    super.performSegueWithIdentifier("showStoriesSegue", sender: self)
                    self.removeLoadingScreen()
                })
            }
        }
        task.resume()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationvc = segue.destinationViewController
        if let storiesvc = destinationvc as? StoriesTableViewController{
                storiesvc.storiesFeed = storyFeed
        }
        
        // prettify
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    private func convertStringToNSURL(url: String) -> NSURL? {
        return NSURL(string: url)
    }
    
    private func fetchData(){
        if let url = programDataURL{
            
            self.setLoadingScreen()
            let request = NSURLRequest(URL: url)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                if error == nil && data != nil {
                    let feed = ProgramsFeed(data: data!, sourceURL: url)
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.programFeed = feed
                        self.removeLoadingScreen()
                    })
                }
            }
            task.resume()
        }
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRectMake(x, y, width, height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.grayColor()
        self.loadingLabel.textAlignment = NSTextAlignment.Center
        self.loadingLabel.text = "Loading..."
        self.loadingLabel.hidden = false
        self.loadingLabel.frame = CGRectMake(0, 0, 140, 30)
        
        // Sets spinner
        self.loadingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.loadingSpinner.frame = CGRectMake(0, 0, 30, 30)
        self.loadingSpinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.loadingSpinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        // Hides and stops the text and the spinner
        self.loadingSpinner.stopAnimating()
        self.loadingLabel.hidden = true
    }
    
    
    @IBAction func revealSideMenuButton(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    
}
