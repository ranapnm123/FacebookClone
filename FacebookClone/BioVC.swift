//
//  BioVC.swift
//  FacebookClone
//
//  Created by Ravindra on 31/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class BioVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var bioTexView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bioTexView.layer.borderColor = UIColor.lightGray.cgColor
        bioTexView.layer.borderWidth = 2.0
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true

        // Do any additional setup after loading the view.
        
        loadUser()
    }
    
    func loadUser() {
        
       guard let firstName = Helper.getUserDetails()?.firstName,
              let lastName = Helper.getUserDetails()?.lastName,
               let avatarImageUrl = Helper.getUserDetails()?.avatar else { return }
              
             
        Helper.loadFullname(firstName: firstName, lastName: lastName, showIn: fullNameLabel)
           Helper.downloadImage(path: avatarImageUrl, showIn: profileImageView, placeholderImage: "user.jpg")
        
       }
    
    func textViewDidChange(_ textView: UITextView) {
        let allowed = 101
        let typed = textView.text.count
        let remaining = allowed - typed
        
        countLabel.text = "\(remaining)/101"
        
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        } else {
            placeHolderLabel.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
        return textView.text.count + (text.count - range.length) <= 101
    }
    
    @IBAction func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction() {
        if (bioTexView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) {
        updateBio()
        }
    }
    
    func updateBio() {
        guard let id = Helper.getUserDetails()?.id else { return }
        
        //send bio notification to server
            ApiClient.shared.updateNotification(action: "insert", byUserId: id, userId: id, type: "bio") { (response:NotificationCodable?, error) in
                
            }
        
        ApiClient.shared.updateBio(id: id, bio: bioTexView.text) { (response:LoginResponse?, error) in
            if error != nil {
            
                    return
                }
              DispatchQueue.main.async {
                if response?.status == "200" {
                    
                    Helper.saveUserDetails(object: response!, password: Helper.getUserDetails()?.password)
                 
//                    Helper.showAlert(title: "Success", message: (response?.message)!, in: self)
                    self.dismiss(animated: true) {
                        bioAddedCallback((response?.bio)!)
                    }

                } else {
                    Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                    }
                    
                }
        }
    }
}
