//
//  ForumAddCommentTableViewCell.swift
//  Homework3
//
//  Created by Carlos Rosario on 8/6/16.
//  Copyright © 2016 Carlos Rosario. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase

class ForumAddCommentTableViewCell: UITableViewCell, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    let rootRef = FIRDatabase.database().reference()
    weak var parent : UITableViewController?
    var auxImageSelected = false
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var auxImageView: UIImageView!
    
    @IBAction func addPhotoTouched(sender: UIButton) {
        handleSelectProfileImageView()
    }
    
    @IBAction func postNewCommentTouched(sender: UIButton) {
        if commentTextField.text == "" && auxImageSelected == false {
            AppDelegate.showMessage("Oops!", message: "Please enter a comment and/or select an image", VC: parent!)
        }
        else {
            
            if auxImageSelected == true {
                // Push image to firebase storage
                let uuid = NSUUID().UUIDString
                let storageRef = FIRStorage.storage().reference().child("auxcomment_images").child(uuid)
                
                if let uploadData = UIImagePNGRepresentation(self.auxImageView.image!){
                    // Push image to firebase storage
                    AppDelegate.showLoading("Loading your image to the cloud...", thisView: parent!.view)
                    storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                        if error != nil {
                            print(error)
                            AppDelegate.hideLoading(self.parent!.view)
                            return
                        }
                        else {
                            if let auxCommentsimageURL = metadata?.downloadURL()?.absoluteString {
                                
                                if let currentUser = AppDelegate.currentUser {
                                    if let profileImageURL = currentUser.imageURL {
                                        self.storeForumCommentToFirebase(profileImageURL, auxImageURL: auxCommentsimageURL)
                                    }
                                    else {
                                        self.storeForumCommentToFirebase("", auxImageURL: auxCommentsimageURL)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                
                if let currentUser = AppDelegate.currentUser {
                    if let profileImageURL = currentUser.imageURL {
                        storeForumCommentToFirebase(profileImageURL, auxImageURL: "")
                    }
                    else {
                        storeForumCommentToFirebase("", auxImageURL: "")
                    }
                }
            }
        }
    }
    
    private func storeForumCommentToFirebase(creatorImageURL: String, auxImageURL: String){
        // Store message on firebase
        AppDelegate.showLoading("Sending comment...", thisView: parent!.view)
        let currentUser = AppDelegate.currentUser
        let forumCommentReference = self.rootRef.child("ForumComments").child(forum!.forumID!).childByAutoId()
        
        let newForumComment = ForumComments()
        newForumComment.creatorEmail = currentUser?.emailAddress
        newForumComment.creatorID = currentUser?.firebaseGeneratedId
        newForumComment.creatorName = (currentUser?.firstName)! + " " + (currentUser?.lastName)!
        newForumComment.forumCommentText = commentTextField.text
        newForumComment.forumCommentKey = forumCommentReference.key
        newForumComment.creatorImageURL = creatorImageURL
        newForumComment.auxImageURL = auxImageURL
        
        let forumcomment = [
            "creatorEmail": newForumComment.creatorEmail!,
            "creatorID": newForumComment.creatorID!,
            "creatorName": newForumComment.creatorName!,
            "forumCommentText" : newForumComment.forumCommentText!,
            "forumCommentKey" : newForumComment.forumCommentKey!,
            "creatorImageURL" : newForumComment.creatorImageURL!,
            "auxImageURL" : newForumComment.auxImageURL!
            ] as [String: String]
        
        forumCommentReference.setValue(forumcomment){
            (error, reference) in
            
            if(error != nil){
                print(error)
                AppDelegate.hideLoading(self.parent!.view)
                return
            }
            else {
                print("successfully loaded message")
                AppDelegate.hideLoading(self.parent!.view)
                self.parent!.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    var forum : Forum?
    
    override func awakeFromNib() {
        // Set Image
        if AppDelegate.currentUser?.imageURL == "" {}
        else {
            let imageURL:NSURL? = NSURL(string: (AppDelegate.currentUser?.imageURL)!)
            if let url = imageURL{
                profileImageView.sd_setImageWithURL(url)
            }
        }
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
            auxImageSelected = true
            auxImageView.image = selectedImage
        }
        
        //updateFirebase()
        parent!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        parent!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true // allows you to crop image before saving
        parent!.presentViewController(picker, animated: true, completion: nil)
    }
    
    
}
