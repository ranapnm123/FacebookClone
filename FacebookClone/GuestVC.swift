//
//  GuestVC.swift
//  FacebookClone
//
//  Created by Ravindra on 19/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class GuestVC: UITableViewController {

    struct FollowUser:Codable {
        let status:  String
        let message: String
    }
    
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
    var allowFriends = Int()
    var allowFollow = Int()
    var isfollowed = Int()
    
    var posts = [Post]()
    var skip = 0
    var limit = 4
    var isLoading = false
    var liked = [Int]()

    var friendshipStatus = 0

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendButton.centerVertically(gap: 10)
        followButton.centerVertically(gap: 10)
        messageButton.centerVertically(gap: 10)
        moreButton.centerVertically(gap: 10)
        
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
        
        if allowFriends == 0 {
            friendButton.isEnabled = false
        }
        
        if allowFollow == 0 {
            followButton.isEnabled = false
        }
        
        
        if isfollowed != 0  {
            button(with: followButton, image: "follow.png", tintColor: Helper().facebookColor, title: "Following")
            followButton.isEnabled = true
        }
        
        fullNameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        bioLabel.text = bio
        
        if bio.isEmpty {
            headerView.frame.size.height -= 45
        }
        
        //not request
        if friendshipStatus == 0 {
            
            self.button(with: self.friendButton, image: "unfriend.png", tintColor: .darkGray, title: "Add")
            
            //current user requested by the guest-user
        } else if friendshipStatus == 1 {
          
            
            self.button(with: self.friendButton, image: "request.png", tintColor: Helper().facebookColor, title: "Requested")
            //user requested current user to be his friend
        } else if friendshipStatus == 2 {
            self.button(with: self.friendButton, image: "respond.png", tintColor: Helper().facebookColor, title: "Respond")
          //they are friend
        } else if friendshipStatus == 3 {
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
            
            //send like notification to server
            if action == "insert" {
                ApiClient.shared.updateNotification(action: "insert", byUserId: id, userId: String(self.id), type: "like") { (response:NotificationCodable?, error) in
                    
                }
            } else if action == "delete" {
                ApiClient.shared.updateNotification(action: "delete", byUserId: id, userId: String(self.id), type: "like") { (response:NotificationCodable?, error) in
                    
                }
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
    
    
    func updateFriendshipRequest(action:String, userId:String, friendId:Int, indexPathRow:Int) {
        //send friend notification to server
        if action == "confirm" {
            ApiClient.shared.updateNotification(action: "insert", byUserId: userId, userId: String(friendId), type: "friend") { (response:NotificationCodable?, error) in
                
            }
        } else if action == "delete" {
            ApiClient.shared.updateNotification(action: "delete", byUserId: userId, userId: String(friendId), type: "friend") { (response:NotificationCodable?, error) in
                
            }
        }
        
        ApiClient.shared.friendRequest(action: action, userId: userId, friendId: String(friendId)) { (response:searchResponseCodable?, error) in
                    if error != nil {
                               DispatchQueue.main.async {
                                           Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                                    return
                                    }
                                }
                               
                    if response?.status == "200" {
                               DispatchQueue.main.async {
                                self.friendRequestCallback(self.friendshipStatus)
                               }
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
    
    @IBAction func friendButtonAction(_ sender: UIButton) {
        guard let currentUseIid = Helper.getUserDetails()?.id else { return }
         let friendUserId = id
        
         //current use didn't sent friend request -> send it
         if friendshipStatus == 0 {
             
             self.friendshipStatus = 1
             
             button(with: sender, image: "request.png", tintColor: Helper().facebookColor, title: "Requested")
             
             updateFriendshipRequest(action: "add", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
             
         }
         //current user sent friendship request -> cancel it
         else if friendshipStatus == 1 {
             //update button
             button(with: sender, image: "unfriend.png", tintColor: .darkGray, title: "Add")
             
             self.friendshipStatus = 0
             //send request
             updateFriendshipRequest(action: "reject", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
            
         }
              //current user received friendship request -> accept/reject actionsheet
         else if friendshipStatus == 2 {
             Helper().showActionSheet(options: ["Delete","Confirm"], isCancel: true, destructiveIndexes: [0], title: nil, message: nil, showIn: self) { (actionButtonIndex) in
                 switch actionButtonIndex {
                 case 0:
                     //udpate status -> no more any relations
                     self.friendshipStatus = 0
                     self.button(with: sender, image: "unfriend.png", tintColor: .darkGray, title: "Add")
                     self.updateFriendshipRequest(action: "reject", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
                     self.updateFriendshipRequest(action: "reject", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)

                 case 1:
                     //update status -> now friends
                     self.friendshipStatus = 3
                     self.button(with: sender, image: "friends.png", tintColor: Helper().facebookColor, title: "Friends")
                     self.updateFriendshipRequest(action: "confirm", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)

                 default: break
                 }
                 
             }
             
         }
             //current user and searched user are friend -> show actionsheet
         else if friendshipStatus == 3 {
             Helper().showActionSheet(options: ["Delete"], isCancel: true, destructiveIndexes: [0], title: nil, message: nil, showIn: self) { (actionButtonIndex) in
                 switch actionButtonIndex {
                 case 0:
                     self.friendshipStatus = 0
                     self.button(with: sender, image: "unfriend.png", tintColor: .darkGray, title: "Add")
                     self.updateFriendshipRequest(action: "delete", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
                     self.updateFriendshipRequest(action: "delete", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)


                 default: break
                 }
                 
             }
             //show actionsheet to update friendship: delete
         }
                /*guard let userId = Helper.getUserDetails()?.id else { return }
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
                */
                
                
               
            }

    
    @IBAction func followButtonAction(_ sender: UIButton)  {
        
        if isfollowed != 0 {
            button(with: followButton, image: "unfollow.png", tintColor: .darkGray, title: "Follow")
        } else {
            button(with: followButton, image: "follow.png", tintColor: Helper().facebookColor, title: "Following")
        }
        
        let status = isfollowed != 0 ? "unfollow" : "follow"

        guard let userId = Helper.getUserDetails()?.id else {
            return
        }
        let followUserId = id
        
        //send follow notification to server
         if status == "follow" {
               ApiClient.shared.updateNotification(action: "insert", byUserId: userId, userId: String(followUserId), type: "follow") { (response:NotificationCodable?, error) in
                   
                   }
               } else if status == "unfollow" {
               ApiClient.shared.updateNotification(action: "delete", byUserId: userId, userId: String(followUserId), type: "follow") { (response:NotificationCodable?, error) in
                   
                   }
               }
        
        
        
        ApiClient.shared.updateFollowUser(action: status, userId: userId, followUserId: String(followUserId)) { (response:FollowUser?, error) in
            if error != nil {
                DispatchQueue.main.async {
                Helper.showAlert(title: "Error", message: response!.message, in: self)

                }
                return
            }
            
                DispatchQueue.main.async {
//                Helper.showAlert(title: "Success", message: response!.message, in: self)
                    self.isfollowed = self.isfollowed != 0 ? 0 : self.id
                }
        }
    }

    fileprivate func showAlertToReport(postId: String) {
        let alert = UIAlertController.init(title: "Report", message: "Please explain the reason", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
        }
        let report = UIAlertAction.init(title: "Send", style: .default) { (action) in
            self.report(postId: postId, userId: String(self.id), reason: alert.textFields!.first!.text!)
        }
        alert.addAction(cancel)
        alert.addAction(report)
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Please provide more details"
            textField.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        })
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        Helper().showActionSheet(options: ["Report User"], isCancel: true, destructiveIndexes: [3], title: nil, message: nil, showIn: self) { (action) in
            if action == 0 {
                self.showAlertToReport(postId: "0")
            }
        }
    }
    
    @IBAction func optionsButtonAction(_ sender: Any) {
        guard let postId = self.posts[(sender as AnyObject).tag].postId else { return }
        Helper().showActionSheet(options: ["Report Post"], isCancel: true, destructiveIndexes: [3], title: nil, message: nil, showIn: self) { (action) in
                   if action == 0 {
                       self.showAlertToReport(postId: postId)
                   }
               }
    }
    
    func report(postId:String, userId:String, reason:String) {
        guard let byUserId = Helper.getUserDetails()?.id else { return }
        ApiClient.shared.report(postId: postId, userId: userId, reason: reason, byUserId: byUserId) { (response: FollowUser?, error) in
            if error != nil {
                return
            }
            
            if response?.status == "200" {
                print("\(response?.message ?? "")")
            }
        }
        
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
        
        cell.optionButton.tag = indexPath.row
        
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
            vc?.postOwnerId = posts[((sender as? UIButton)?.tag)!].postUserId

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
    func centerVertically(gap:CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: -15)
        
        let padding = self.frame.height + gap
        
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
    }
}
