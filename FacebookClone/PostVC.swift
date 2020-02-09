//
//  PostVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 08/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    struct PostResponse:Codable {
        let status: String
        let message: String
        let folder_message:String?
    }
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var addPicBtn: UIButton!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageViewForPost: UIImageView!
    var isPictureSelected:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImgView.layer.cornerRadius = profileImgView.frame.width / 2
        profileImgView.clipsToBounds = true
        
        loadUser()
    }
    
    func loadUser() {
              guard let firstName = Helper.getUserDetails()?.firstName,
              let lastName = Helper.getUserDetails()?.lastName,
               let avatarImageUrl = Helper.getUserDetails()?.avatar else { return }
              
             
        Helper.loadFullname(firstName: firstName, lastName: lastName, showIn: fullNameLbl)
           Helper.downloadImage(path: avatarImageUrl, showIn: profileImgView, placeholderImage: "user.jpg")

             
          }
    
    func textViewDidChange(_ textView: UITextView) {
           let allowed = 101
           let typed = textView.text.count
           let remaining = allowed - typed
           
//           countLabel.text = "\(remaining)/101"
           
           if textView.text.isEmpty {
               placeholderLbl.isHidden = false
           } else {
               placeholderLbl.isHidden = true
           }
       }
       
       func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
               return false
           }
           return textView.text.count + (text.count - range.length) <= 101
       }
    
    func showPicker(with source: UIImagePickerController.SourceType) {
           
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.allowsEditing = true
           picker.sourceType = source
           present(picker, animated: true, completion: nil)
       }
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
           dismiss(animated: true) {
                   self.imageViewForPost.image = image
            self.isPictureSelected = true
//                   self.uploadImage(from: self.profileImageView!)
           }
       }
    
    func showActionSheet() {
           let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
           let camera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
               if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   self.showPicker(with: .camera)
               }
           }
           let photoLibrary = UIAlertAction.init(title: "Library", style: .default) { (action) in
               if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                   self.showPicker(with: .photoLibrary)
               }
           }
           let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
           actionSheet.addAction(camera)
           actionSheet.addAction(photoLibrary)
           actionSheet.addAction(cancel)
           
          
           
           present(actionSheet, animated: true, completion: nil)
           
       }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    @IBAction func postImageViewTapped() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
         let delete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
                self.imageViewForPost.image = UIImage()
                self.isPictureSelected = false
         }
         
         let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
         actionSheet.addAction(delete)
         actionSheet.addAction(cancel)
         
        
         
         present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func AddPictureAction(_ sender: Any) {
        showActionSheet()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        guard let userId = Helper.getUserDetails()?.id, let text = textView.text else {
            return
        }
        var imageData:Data? = nil
        if isPictureSelected {
            imageData = imageViewForPost.image?.jpegData(compressionQuality: 0.5)
        }
        
        ApiClient.shared.updatePost(userId: userId, text: text, imageData: imageData) { (response:PostResponse?, error) in
            DispatchQueue.main.async {
            if error != nil {
                Helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                                return
                            }
                          
                            if response?.status == "200" {
                                
                           Helper.showAlert(title: "Success", message: (response?.message)!, in: self)

                            } else {
                                Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                                }
                                
                            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
