//
//  FeedVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 09/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class FeedVC: UITableViewController {

      private var posts = [Post]()
      var skip = 0
      var limit = 5
      var isLoading = false
      var liked = [Int]()
    
    lazy private var refreshControlHome: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                     #selector(HomeVC.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
     
        loadPosts(offset: skip, limit: limit)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refreshControlHome)
        loadPosts(offset: skip, limit: limit)
    }

     private func loadPosts(offset: Int, limit: Int) {
            if refreshControlHome.isRefreshing {
                refreshControlHome.endRefreshing()
            }
            
               guard let id = Helper.getUserDetails()?.id else { return }

            ApiClient.shared.getPosts(action: "feed", id: id, offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
                 DispatchQueue.main.async {
                   if error != nil {
                           return
                       }
                    
                       print("posts == \(response!)")
                        self.posts.removeAll(keepingCapacity: false)
                        self.liked.removeAll(keepingCapacity: false)
                    
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

          private func loadMore(offset: Int, limit: Int) {
                
                isLoading = true
                guard let id = Helper.getUserDetails()?.id else { return }

                ApiClient.shared.getPosts(action: "feed", id: id, offset: String(offset), limit: String(limit)) { (response:userPostResponse?, error) in
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
                ApiClient.shared.updateNotification(action: "insert", byUserId: id, userId: id, type: "like") { (response:NotificationCodable?, error) in
                    
                }
            } else if action == "delete" {
                ApiClient.shared.updateNotification(action: "delete", byUserId: id, userId: id, type: "like") { (response:NotificationCodable?, error) in
                    
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
        
    @IBAction func optionButtonAction(_ sender: UIButton) {
        
        guard let postId = self.posts[sender.tag].postId else { return }
        let alert = UIAlertController()
        let delete = UIAlertAction(title: "Delete Post", style: .destructive) { (action) in
            
            ApiClient.shared.deletePost(postId: postId) { (response:likeCodable?, error) in
                if error != nil {
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                DispatchQueue.main.async {
                    if response?.status == "200" {
                        self.posts.remove(at: sender.tag)
                        let indexPath = IndexPath(row: sender.tag, section: 0)
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             let post = posts[(sender as! UIButton).tag]
             let firstName = post.userFirstName
            let lastName = post.userLastName
           let fullName = "\(firstName) \(lastName)".capitalized
            
            if segue.identifier == "Comment" {
                let vc = segue.destination as? CommentsVC
                    
//                vc?.profileImage = self.profileImageView.image ?? UIImage()
                vc?.fullNameString = fullName
                vc?.dateString = posts[((sender as? UIButton)?.tag)!].postdateCreated

                vc?.textString = posts[((sender as? UIButton)?.tag)!].postText
                vc?.postId = posts[((sender as? UIButton)?.tag)!].postId!
                vc?.postOwnerId = (Helper.getUserDetails()?.id)!

                let indexpath = IndexPath(row: ((sender as? UIButton)?.tag)!, section: 0)
                guard let cell = tableView.cellForRow(at: indexpath) as? PicCell else {
                    return
                }
                vc?.pictureImage = cell.postImageView.image!
                
            }
        }
    
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let tableVeiwH = tableView.contentOffset.y - tableView.contentSize.height + 60
//        if tableVeiwH > -tableView.frame.height && isLoading == false {
//            loadMore(offset: skip, limit: limit)
//        }
//    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let picture = posts[indexPath.row]
            
        
            if picture.postPicture.isEmpty {
                let emptyCell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as? NoPicCell
                
                emptyCell?.fullNameLabel.text = "\(picture.userFirstName.capitalized) \(picture.userLastName.capitalized)"
                
                emptyCell?.dateLabel.text = Helper.formatDate(dateString:picture.postdateCreated)
                
                emptyCell?.postTextLabel.text = picture.postText
                
                emptyCell?.profileImageUrl = picture.userAvatar

                emptyCell?.likeButton.tag = indexPath.row
                emptyCell?.commentButton.tag = indexPath.row
                emptyCell?.optionButton.tag = indexPath.row
             
             DispatchQueue.main.async {
                 if self.liked[indexPath.row] == 1 {
                     emptyCell?.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
                     emptyCell?.likeButton.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
                 } else {
                     
                     emptyCell?.likeButton.setImage(UIImage(named:"unlike.png"), for: .normal)
                     emptyCell?.likeButton.tintColor = .darkGray
                 }
             }
             
                return emptyCell!
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as? PicCell
                
                cell?.fullNameLabel.text = "\(picture.userFirstName.capitalized) \(picture.userLastName.capitalized)"
                
                cell?.dateLabel.text = Helper.formatDate(dateString:picture.postdateCreated)
                
                cell?.postTextLabel.text = picture.postText
             
                cell?.profileImageUrl = picture.userAvatar
             
                cell?.postPictureUrl = picture.postPicture

                cell?.likeButton.tag = indexPath.row
                cell?.commentButton.tag = indexPath.row
                cell?.optionButton.tag = indexPath.row
             
                 DispatchQueue.main.async {
                    if self.liked[indexPath.row] == 1 {
                         cell?.likeButton.setImage(UIImage(named:"like.png"), for: .normal)
                         cell?.likeButton.tintColor = UIColor(red: 59/255, green: 87/255, blue: 157/255, alpha: 1)
                         } else {
                             
                     cell?.likeButton.setImage(UIImage(named:"unlike.png"), for: .normal)
                             cell?.likeButton.tintColor = .darkGray
                     }
                 }
             
                return cell!
            }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == self.posts.count - 1) {
        loadMore(offset: skip, limit: limit) // network request to get more data
        }
    }

}
