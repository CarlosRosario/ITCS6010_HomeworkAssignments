//
//  InviteViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Alamofire

class InviteViewController: UIViewController {

    @IBOutlet weak var inviteEmailTextField: UITextField!
    @IBOutlet weak var inviteMessageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteMessageTextView.layer.borderWidth = 2.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    
    
    @IBAction func cancelTouched(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func submitTouched(sender: UIButton) {
        
        if inviteEmailTextField.text != "" {
        
            sendEmail(inviteEmailTextField.text!, emailText: inviteMessageTextView.text)
            
        }
        else {
            AppDelegate.showMessage("Oops!", message: "Please specify an email address you would like to send an email to", VC: self)
        }
        
    }
    
    
    private func sendEmail(toEmail: String, emailText: String){
        let key = "key-45722c49185c1dc59d516c97409378da"
        
        let parameters = [
            //"from": "postmaster@sandbox19ca62ebfbd44e2b995c8663e73bf9c8.mailgun.org",
            "from": (AppDelegate.currentUser?.emailAddress)!,
            "to": toEmail,
            "subject": "Greetings!",
            "text": emailText
        ] as [String: AnyObject]
        
        let request = Alamofire.request(.POST, "https://api.mailgun.net/v3/sandbox19ca62ebfbd44e2b995c8663e73bf9c8.mailgun.org/messages", parameters:parameters)
            .authenticate(user: "api", password: key)
            .response { (request, response, data, error) in
                print(request)
                print(response)
                print(error)
        }
        print(request)
        
    }

}
