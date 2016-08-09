//
//  ProfileViewController.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/5/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var avatarImage: UIImage!
    var newImageSelected = false
    let rootRef = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Make the image circular
        profileImageView.layer.borderWidth=1.0
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.borderColor = UIColor.blackColor().CGColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        
        if !newImageSelected {
            // Pre-populate profile image if it exists
            if let foundProfileImageURL = AppDelegate.currentUser?.imageURL{
                let imageURL:NSURL? = NSURL(string: foundProfileImageURL)
                if let url = imageURL{
                    profileImageView.sd_setImageWithURL(url)
                }
            }
        }
        
        // Pre-populate name and email labels
        fullNameLabel.text = (AppDelegate.currentUser?.firstName)! + " " + (AppDelegate.currentUser?.lastName)!
        emailLabel.text = AppDelegate.currentUser?.emailAddress
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            newImageSelected = true
            profileImageView.image = selectedImage
        }
        
        updateFirebase()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateFirebase(){
        // Push image to firebase storage
        let uuid = NSUUID().UUIDString
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(uuid)
        
        if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!){
            // Push image to firebase storage
            AppDelegate.showLoading("Loading your image to the cloud...", thisView: self.view)
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error)
                    AppDelegate.hideLoading(self.view)
                    return
                }
                else {
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        // Push image to firebase database
                        let currentUser = AppDelegate.currentUser
                        let userChild = currentUser?.firebaseGeneratedId
                        let userImageReference = self.rootRef.child("Users").child(userChild!)
                        let values = ["imageURL" : imageURL]
                        userImageReference.updateChildValues(values){
                            (error, reference) in
                            
                            if(error != nil){
                                print(error)
                                AppDelegate.hideLoading(self.view)
                                return
                            }
                            else {
                                AppDelegate.currentUser?.imageURL = imageURL
                                AppDelegate.hideLoading(self.view)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true // allows you to crop image before saving
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func changePhotoTouched(sender: UIButton) {
        handleSelectProfileImageView()
    }

    @IBAction func backButtonTouched(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}