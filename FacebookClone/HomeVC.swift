//
//  HomeVC.swift
//  FacebookClone
//
//  Created by Ravindra on 29/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //codable
    struct uploadImageResponse : Codable
    {
        let status: String
        let message: String
        let email: String?
        let firstName: String?
        let lastName: String?
        let birthday: String?
        let gender: String?
        let id: String?
        let cover: String?
        let avatar: String?
    }
    
    @IBOutlet weak var coverImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    
    enum imageViewTapped: String {
        case cover = "cover"
        case avatar = "avatar"
    }
    
    var imagViewType:String?
    var isCoverAva:Bool?
    var isProfileAva:Bool?
    
    override func viewDidLoad() {
        configureProfileImageView()
        super.viewDidLoad()
        
    }
    
    func configureProfileImageView() {
        let layer = CALayer()
        layer.borderWidth = 5
        layer.borderColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: profileImageView.frame.width, height: profileImageView.frame.height)
        profileImageView.layer.addSublayer(layer)
        
        profileImageView.layer.cornerRadius = 10
        profileImageView.clipsToBounds = true
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
            switch self.imagViewType {
            case imageViewTapped.cover.rawValue :
                self.coverImageView.image = image
                self.isCoverAva = true
                self.uploadImage(from: self.coverImageView!)
            case imageViewTapped.avatar.rawValue :
                self.profileImageView.image = image
                self.isProfileAva = true
                self.uploadImage(from: self.profileImageView!)
            default: break
            }
        }
    }

    @IBAction func tapCoverAction(_ sender: UITapGestureRecognizer) {
        imagViewType = imageViewTapped.cover.rawValue
        showActionSheet()
    }
    
    @IBAction func tapUserAction(_ sender: UITapGestureRecognizer) {
    imagViewType = imageViewTapped.avatar.rawValue
    showActionSheet()
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
        let delete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
            switch self.imagViewType {
            case imageViewTapped.cover.rawValue :
                self.coverImageView.image = #imageLiteral(resourceName: "HomeCover")
                self.isCoverAva = false
            case imageViewTapped.avatar.rawValue :
                self.profileImageView.image = #imageLiteral(resourceName: "user")
                self.isProfileAva = false
            default: break
            }
        }
        actionSheet.addAction(camera)
        actionSheet.addAction(photoLibrary)
        actionSheet.addAction(cancel)
        actionSheet.addAction(delete)
        
        switch self.imagViewType {
        case imageViewTapped.cover.rawValue :
            
            if self.isCoverAva == true {
                delete.isEnabled = true
            } else {
                delete.isEnabled = false
            }
        case imageViewTapped.avatar.rawValue :
            
            if self.isProfileAva == true {
                delete.isEnabled = true
            } else {
                delete.isEnabled = false
            }
        default: break
        }
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func uploadImage(from imageView:UIImageView) {
        guard let id = Helper.getUserDetails()?.id else { return }
        
        var temp:String?
        if self.imagViewType! == imageViewTapped.cover.rawValue {
            temp = "1"
        } else {
            temp = "2"
        }
        ApiClient.shared.uploadImage(id: id, type: temp!, image: imageView.image!, fileName: self.imagViewType!) { (response: uploadImageResponse?, error) in
        if error != nil {
           
                   return
               }
                print(response!)
             DispatchQueue.main.async {
               if response?.status == "200" {
                   
                   

               } else {
                   Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                   }
                   
               }
        }
        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
}
