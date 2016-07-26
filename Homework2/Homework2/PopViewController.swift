//
//  PopViewController.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/23/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit

class PopViewController: UIViewController {

    var navTitle : String? = nil
    var additionalInformation: String? = nil
    
    @IBOutlet weak var additionalInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make the app a little more pretty
        navigationController?.navigationBar.barTintColor = UIColor(red: 0xff, green: 0x44, blue: 0x44)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        additionalInfoLabel.lineBreakMode = .ByWordWrapping
        additionalInfoLabel.numberOfLines = 0
        
        additionalInfoLabel?.text = additionalInformation
        self.title = navTitle! + " Description"
    }
    
    
    @IBAction func dismissPopOver(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
