//
//  HomeVC.swift
//  FacebookClone
//
//  Created by Ravindra on 29/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

var bioAddedCallback = {(bioText:String) -> () in }

var profileUpdateCallback = {() -> () in }
var newPostAddedCallback = {() -> () in }

struct Global {
        static var postAvas = [UIImage]()
        static var postPicture = [UIImage]()
}
class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

   
    //codable
       struct postCodable: Codable {
           let id: Int
           let user_id: Int
           let text: String?
           let picture: String?
           let date_created: String
           let firstName: String
           let lastName: String
           let cover: String?
           let avatar: String?
           let liked: String?
       }
       
       struct userPostResponse:Codable {
           let posts: [postCodable]
       }
    
    struct likeCodable: Codable {
        let status: String
        let message: String
    }
       
    @IBOutlet weak var coverImageView:UIImageView!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var fullNameLabel:UILabel!
    @IBOutlet weak var addBioBtn:UIButton!
    @IBOutlet weak var bioLabel:UILabel!
    
    enum imageViewTapped: String {
        case cover = "cover"
        case avatar = "avatar"
    }
    
    var imagViewType:String?
    var isCoverAva:Bool?
    var isProfileAva:Bool?
    var isLoading = false
    
    
    //params for post
    struct Post {
        let postId: String?
        let postUserId: String
        let postText: String
        let postPicture: String
        let postdateCreated: String
        let userFirstName: String
        let userLastName: String
        let userCover: String
        let userAvatar: String
        let liked:String
    }
    
    var posts = [Post]()
    var skip = 0
    var limit = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        overrideUserInterfaceStyle = .dark
        configureProfileImageView()
        loadUser()
        
        bioAddedCallback = { bio in
            if bio.isEmpty {
                self.bioLabel.isHidden = true
                self.addBioBtn.isHidden = false
                
            } else {
                self.bioLabel.text = bio
                self.bioLabel.isHidden = false
                self.addBioBtn.isHidden = true
            }
        }
        
        profileUpdateCallback = {
            self.loadUser()
        }
        
        newPostAddedCallback = {
            self.loadPosts(offset: 0, limit: self.skip + 1)
        }
        loadPosts(offset: skip, limit: limit)

    }
    
    func loadUser() {
        guard let firstName = Helper.getUserDetails()?.firstName,
        let lastName = Helper.getUserDetails()?.lastName,
        let coverImageUrl = Helper.getUserDetails()?.cover,
        let avatarImageUrl = Helper.getUserDetails()?.avatar,
        let bio = Helper.getUserDetails()?.bio else { return }
        
        fullNameLabel.text = "\(firstName) \(lastName)".capitalized
       
        if coverImageUrl.count > 10 {
            isCoverAva = true
        } else {
            self.coverImageView.image = UIImage(named: "HomeCover.jpg")
            isCoverAva = false
        }
        Helper.downloadImage(path: coverImageUrl, showIn: self.coverImageView, placeholderImage: "HomeCover.jpg")
        
        if avatarImageUrl.count > 10 {
            isProfileAva = true
        } else {
            self.profileImageView.image = UIImage(named: "user.png")
            isProfileAva = false
        }
        Helper.downloadImage(path: avatarImageUrl, showIn: self.profileImageView, placeholderImage: "user.png")
        
        if bio.isEmpty {
            bioLabel.isHidden = true
            addBioBtn.isHidden = false
            
        } else {
            bioLabel.text = bio
            bioLabel.isHidden = false
            addBioBtn.isHidden = true
        }
        
       
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
                self.uploadImage(from: self.coverImageView)
                
            case imageViewTapped.avatar.rawValue :
                self.profileImageView.image = #imageLiteral(resourceName: "user")
                self.isProfileAva = false
                self.uploadImage(from: self.profileImageView)
                
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
        
        
        ApiClient.shared.uploadImage(id: id, type: self.imagViewType!, image: imageView.image!, fileName: self.imagViewType!) { (response: LoginResponse?, error) in
        if error != nil {
           
                   return
               }
             DispatchQueue.main.async {
               if response?.status == "200" {
                   
                Helper.saveUserDetails(object: response!, password: Helper.getUserDetails()?.password)
                
                   Helper.showAlert(title: "Success", message: (response?.message)!, in: self)

               } else {
                   Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                   }
                   
               }
        }
        
    }
    
   @IBAction func bioLabelTapped() {
           let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
           let bio = UIAlertAction.init(title: "New Bio", style: .default) { (action) in
               Helper.instantiateViewController(identifier: "BioVC", animated: true, modalStyle: .popover, by: self, completion: nil)
           }
           
           let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
           let delete = UIAlertAction.init(title: "Delete Bio", style: .destructive) { (action) in
            self.deleteBio()
           }
           actionSheet.addAction(bio)
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
    
    func deleteBio() {
        guard let id = Helper.getUserDetails()?.id else { return }
        
        ApiClient.shared.updateBio(id: id, bio: "") { (response:LoginResponse?, error) in
            if error != nil {
            
                    return
                }
              DispatchQueue.main.async {
                if response?.status == "200" {
                    
                    Helper.saveUserDetails(object: response!, password: Helper.getUserDetails()?.password)
                 
                    bioAddedCallback(response?.bio ?? "")
                    

                } else {
                    Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                    }
                    
                }
        }
    }
    
    @IBAction func addBioAction() {
        Helper.instantiateViewController(identifier: "BioVC", animated: true, modalStyle: .overCurrentContext, by: self, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return posts.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let picture = posts[indexPath.row]
           
       
           if picture.postPicture.isEmpty {
               let emptyCell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as? NoPicCell
               
               emptyCell?.fullNameLabel.text = "\(picture.userFirstName.capitalized) \(picture.userLastName.capitalized)"
               
               emptyCell?.dateLabel.text = picture.postdateCreated
               
               emptyCell?.postTextLabel.text = picture.postText
               
//                if posts.count != Global.postAvas.count {
                    emptyCell?.profileImageUrl = picture.userAvatar
//                } else {
//                    emptyCell?.profileImageView.image = Global.postAvas[indexPath.row]
//                }
//               Global.postPicture.append(UIImage())
            emptyCell?.likeButton.tag = indexPath.row

               return emptyCell!
               
           } else {
               let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as? PicCell
               
               cell?.fullNameLabel.text = "\(picture.userFirstName.capitalized) \(picture.userLastName.capitalized)"
               
               cell?.dateLabel.text = picture.postdateCreated
               
               cell?.postTextLabel.text = picture.postText
               
                
            
//            if posts.count != Global.postPicture.count {
                cell?.profileImageUrl = picture.userAvatar
                cell?.postPictureUrl = picture.postPicture
//            } else {
//                cell?.profileImageView.image = Global.postAvas[indexPath.row]
//                cell?.postImageView.image = Global.postPicture[indexPath.row]
//            }
            cell?.likeButton.tag = indexPath.row
               return cell!
           }
           
        
       }

    override func tableView(_ tableView: UITableView,
     willDisplay cell: UITableViewCell,
     forRowAt indexPath: IndexPath)
    {
     // At the bottom...
     if (indexPath.row == self.posts.count - 1) {
     loadMore(offset: skip, limit: limit) // network request to get more data
     }
    }
    
       func loadPosts(offset: Int, limit: Int) {
        self.posts.removeAll()
           guard let id = Helper.getUserDetails()?.id else { return }

           ApiClient.shared.getPosts(id: id, offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
               if error != nil {
                   Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                       return
                   }
                 DispatchQueue.main.async {
                   print("posts == \(response!)")
                   
                   for object in response!.posts {
                    let post = Post(postId: String(object.id), postUserId: String(object.user_id), postText: object.text!, postPicture: object.picture!, postdateCreated: object.date_created, userFirstName: object.firstName, userLastName: object.lastName, userCover: object.cover!, userAvatar: object.avatar!, liked: object.liked!)
                       
                       self.posts.append(post)
                   }
                   self.tableView.reloadData()
                    self.skip += response!.posts.count
                   }
           }
           
           
       }

        func loadMore(offset: Int, limit: Int) {
            
            isLoading = true
            guard let id = Helper.getUserDetails()?.id else { return }

            ApiClient.shared.getPosts(id: id, offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
                if error != nil {
                    self.isLoading = false
                        return
                    }
                DispatchQueue.main.async {
                    print("posts == \(response!)")
                    
                    self.tableView.beginUpdates()
                    for (index, object) in response!.posts.enumerated() {
                        let post = Post(postId: String(object.id), postUserId: String(object.user_id), postText: object.text!, postPicture: object.picture!, postdateCreated: object.date_created, userFirstName: object.firstName, userLastName: object.lastName, userCover: object.cover!, userAvatar: object.avatar!, liked: object.liked!)
                        
                        self.posts.append(post)
                        
                       let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        
                        let pathToLastRow = IndexPath(row: lastRowIndex + index, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    self.tableView.endUpdates()
                    self.isLoading = false
                    self.skip = self.posts.count
                    }
            }
        }
    @IBAction func likeButtonAction(_ sender: UIButton) {
        sender.setImage(UIImage(named: "like.png"), for: .normal)
        
        
        guard let id = Helper.getUserDetails()?.id,
            let postId = self.posts[sender.tag].postId else { return}
        
        ApiClient.shared.likePost(userId: id, postId: postId, action: "insert") { (response:likeCodable?, error) in

            if error != nil {
                Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
              DispatchQueue.main.async {
//                Helper.showAlert(title: "like", message: response!.message, in: self)

                }
        }
    }
    
}
