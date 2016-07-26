//
//  MainNavigationController.swift
//  Homework2
//
//  Created by Carlos Rosario on 7/24/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import ENSwiftSideMenu

class MainNavigationController: ENSideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let menu = storyboard.instantiateViewControllerWithIdentifier("SideMenuTableViewController") as! SideMenuTableViewController
        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menu, menuPosition: ENSideMenuPosition.Right)
        sideMenu?.menuWidth = 300
        view.bringSubviewToFront(navigationBar)
    }
}
