//
//  GuestVC.swift
//  FacebookClone
//
//  Created by Ravindra on 19/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class GuestVC: UITableViewController {

    var friendRequestCallback = {(status:Int)->Void in}

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var profileImageView:UIImageView!
    @IBOutlet weak var coverImageView:UIImageView!
    @IBOutlet weak var fullNameLabel:UILabel!
    @IBOutlet weak var bioLabel:UILabel!

    var id = Int()
    var firstName = String()
    var lastName = String()
    var avaPath = String()
    var coverPath = String()
    var bio = String()
    
    var posts = [Post]()
    var skip = 0
    var limit = 4
    var isLoading = false
    var liked = [Int]()

    var requested = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendButton.centerVertically()
        followButton.centerVertically()
        messageButton.centerVertically()
        moreButton.centerVertically()
        
       tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 563
        
        configureProfileImageView()
        loaduser()
        loadPosts(offset: skip, limit: limit)
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
    
    func loaduser() {
        if avaPath.count < 10 {
            profileImageView.image = UIImage(named: "user.png")
        } else {
            profileImageView.downloaded(from: URL(string: avaPath)!, contentMode: .scaleAspectFill)
        }
        
        if coverPath.count < 10 {
            coverImageView.image = UIImage(named: "HomeCover.png")
        }else {
            coverImageView.downloaded(from: URL(string: coverPath)!, contentMode: .scaleAspectFill)
        }
        
        fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        bioLabel.text = bio
        
        if bio.isEmpty {
            headerView.frame.size.height -= 45
        }
        
        //not request
        if requested == 0 {
            
            self.button(with: self.friendButton, image: "unfriend.png", tintColor: .darkGray, title: "Add")
            
            //current user requested by the guest-user
        } else if requested == 1 {
          
            
            self.button(with: self.friendButton, image: "request.png", tintColor: Helper().facebookColor, title: "Requested")
            //user requested current user to be his friend
        } else if requested == 2 {
            self.button(with: self.friendButton, image: "respond.png", tintColor: Helper().facebookColor, title: "Respond")
          //they are friend
        } else if requested == 4{
            self.button(with: self.friendButton, image: "friends.png", tintColor: Helper().facebookColor, title: "Friend")
        }
    }
    
    func loadPosts(offset: Int, limit: Int) {
     

        ApiClient.shared.getPosts(id: String(id), offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
          DispatchQueue.main.async {
            if error != nil {
                Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
             
                print("posts == \(response!)")
                 self.posts.removeAll(keepingCapacity: false)
//             self.liked.removeAll(keepingCapacity: false)
             
                for object in response!.posts {
                 let post = Post(postId: String(object.id), postUserId: String(object.user_id), postText: object.text!, postPicture: object.picture!, postdateCreated: object.date_created, userFirstName: object.firstName, userLastName: object.lastName, userCover: object.cover!, userAvatar: object.avatar!, liked: object.liked ?? 0)
                    
                    self.posts.append(post)
                 
                 if object.liked == nil {
                     self.liked.append(Int())
                 } else {
                     self.liked.append(1)
                 }
                }
                self.tableView.reloadData()
                 self.skip += response!.posts.count
                }
        }
        
        
    }

    func loadMorePosts(offset: Int, limit: Int) {
        
        isLoading = true

        ApiClient.shared.getPosts(id: String(id), offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
            if error != nil {
                self.isLoading = false
                    return
                }
            DispatchQueue.main.async {
                print("posts == \(response!)")
                
                self.tableView.beginUpdates()
                for (index, object) in response!.posts.enumerated() {
                    let post = Post(postId: String(object.id), postUserId: String(object.user_id), postText: object.text!, postPicture: object.picture!, postdateCreated: object.date_created, userFirstName: object.firstName, userLastName: object.lastName, userCover: object.cover!, userAvatar: object.avatar!, liked: object.liked ?? 0)
                    
                    self.posts.append(post)
                    
                    if object.liked == nil {
                       self.liked.append(Int())
                   } else {
                       self.liked.append(1)
                   }
                    
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
            
            guard let id = Helper.getUserDetails()?.id,
                let postId = self.posts[sender.tag].postId else { return }
            
            var action = ""
            if liked[sender.tag] == 1 {
                action = "delete"
                self.liked[sender.tag] = Int()
                    sender.setImage(UIImage(named:"unlike.png"), for: .normal)
                    sender.tintColor = .darkGray
            } else {
                action = "insert"
                self.liked[sender.tag] = 1
                    sender.setImage(UIImage(named:"like.png"), for: .normal)
                    sender.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
            }
            
            UIView.animate(withDuration: 0.15, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { (completed) in
                UIView.animate(withDuration: 0.15, animations: {
                    sender.transform = CGAffineTransform.identity
                })
            }
            

            ApiClient.shared.likePost(userId: id, postId: postId, action: action) { (response:likeCodable?, error) in

                if error != nil {
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                        return
                    }
                  DispatchQueue.main.async {
    //                Helper.showAlert(title: "like", message: response!.message, in: self)

                    }
            }
        }
    
    fileprivate func updateFriendShipRequest(with action: String, _ userId: String, _ friendId: String) {
        
        UIView.animate(withDuration: 0.15, animations: {
                        self.friendButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                       }) { (completed) in
                           UIView.animate(withDuration: 0.15, animations: {
                            self.friendButton.transform = CGAffineTransform.identity
                           })
                       }
                       
        
        ApiClient.shared.friendRequest(action: action, userId: userId, friendId: friendId) { (response:searchResponseCodable?, error) in
            if error != nil {
                DispatchQueue.main.async {
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
            }
            print("response === \(response!)")
            if response?.status == "200" {
                DispatchQueue.main.async {
                    if self.requested == 0 {
                        self.requested = 1
                        
                        self.button(with: self.friendButton, image: "request.png", tintColor: Helper().facebookColor, title: "Requested")


                    } else if self.requested == 1 {
                        self.requested = 0
                        
                        self.button(with: self.friendButton, image: "unfriend.png", tintColor: .darkGray, title: "Add")


                    } else if self.requested == 3 {
                        
                        self.button(with: self.friendButton, image: "friends.png", tintColor: Helper().facebookColor, title: "Friends")
                        
                    }
                    self.friendRequestCallback(self.requested)
                }
            }
        }
    }
    
    @IBAction func friendButtonAction(_ sender: UIButton) {
        
                guard let userId = Helper.getUserDetails()?.id else { return }
                     let guestId = id
               
                //currently not requested by current user -> request
                if requested == 0 {
                    
                    updateFriendShipRequest(with: "add", userId, String(guestId))
                   
                    //request already sent by current user -> cancel request
                } else if requested == 1 {
                    
                    updateFriendShipRequest(with: "reject", userId, String(guestId))
                
                    //request is received by current user
                } else if requested == 2 {
                    
                    showActionSheet()
                
                } else if requested == 3 {
                    //delete friend -> unfriend
//                    showActionSheet()
        }
                
                
                
               
            }

    func showActionSheet() {
        
        guard let userId = Helper.getUserDetails()?.id else {
            return
        }
        let guestId = id
        var tempArr = ["Cancel Request", "Confirm Friend"]
        if requested == 3 {
//            tempArr = ["UnFriend"]
        }
        Helper().showActionSheet(options: tempArr, isCancel: true, destructiveIndexes:[0], title: nil, message:nil, showIn: self) { (selected) in
            switch selected {
            case 0:
                print("Cancel Request")
                self.requested = 1
                
                self.updateFriendShipRequest(with: "reject", String(guestId), String(userId))
                
            case 1:
                print("Confirm Friend")
                self.requested = 3
                
                self.updateFriendShipRequest(with: "confirm", String(guestId), String(userId))
                
            default:
                print("default")
            }
        }
        
    }
    
    func button(with button:UIButton, image:String, tintColor:UIColor, title:String) {
        let image = UIImage(named: image)
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = tintColor
        button.setTitle(title, for: .normal)
        button.titleLabel?.textColor = tintColor
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as! PicCell

        let post = posts[indexPath.row]
        cell.fullNameLabel.text = post.userFirstName.capitalized + " " + post.userLastName.capitalized
        cell.dateLabel.text = Helper.formatDate(dateString:post.postdateCreated)
        cell.profileImageView.downloaded(from: URL(string: post.userAvatar)!, contentMode: .scaleAspectFill)
        cell.postTextLabel.text = post.postText
        if !post.postPicture.isEmpty {
        cell.postImageView.downloaded(from: URL(string: post.postPicture)!, contentMode: .scaleAspectFill)
        } else    {
            cell.pictureImageViewHeightConstraint.constant = 0
            cell.updateConstraints()
        }
        
        cell.likeButton.tag = indexPath.row
        cell.commentButton.tag = indexPath.row
        cell.optionButton.tag = indexPath.row
        
        if self.liked[indexPath.row] == 1 {
            cell.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
            cell.likeButton.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
            } else {
                
            cell.likeButton.setImage(UIImage(named:"unlike.png"), for: .normal)
            cell.likeButton.tintColor = .darkGray
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comment" {
            let vc = segue.destination as? CommentsVC
                
            vc?.profileImage = self.profileImageView.image ?? UIImage()
            vc?.fullNameString = fullNameLabel.text ?? ""
            vc?.dateString = posts[((sender as? UIButton)?.tag)!].postdateCreated
            
            vc?.textString = posts[((sender as? UIButton)?.tag)!].postText
            vc?.postId = posts[((sender as? UIButton)?.tag)!].postId!
            
            let indexpath = IndexPath(row: ((sender as? UIButton)?.tag)!, section: 0)
            guard let cell = tableView.cellForRow(at: indexpath) as? PicCell else {
                return
            }
            if let image = cell.postImageView.image {
            vc?.pictureImage = image
            }
        }
    }
  
}

extension UIButton {
    func centerVertically() {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
        
        let padding = self.frame.height + 10
        
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
    }
}
