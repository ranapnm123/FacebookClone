//
//  MyFriendVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 08/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class MyFriendVC: UITableViewController {

    struct MyFriendCodable:Codable {
        let status: String?
        let message: String?
        var friends = [MyFriend]()
    }

    struct MyFriend:Codable {
        let id: Int?
        let user_id : Int?
        let friend_id: Int?
        let date_created: String?
        let friendID: Int?
        let email: String?
        let firstName: String?
        let lastName: String?
        let birthday:String?
        let gender:String?
        let cover: String?
        let avatar: String?
        let bio:String?
        let allow_friends: Int?
        let allow_follow: Int?
    }
    
    struct MyFriendModel {
        let id: Int?
        let user_id : Int?
        let friend_id: Int?
        let date_created: String?
        let friendID: Int?
        let email: String?
        let firstName: String?
        let lastName: String?
        let birthday:String?
        let gender:String?
        let cover: String?
        let avatar: String?
        let bio:String?
        let allow_friends: Int?
        let allow_follow: Int?
    }
    
    
    
    var myFriendResult = [MyFriendModel]()
    
    var myFriendSkip = 0
    var myFriendLimit = 3
    
    var friendshipStatus = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        loadMyFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFriendResult.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendCell", for: indexPath) as! MyFriendCell

        let object = myFriendResult[indexPath.row]
        let fName = object.firstName
        let lName = object.lastName
        let fullName = fName!.capitalized + " " + lName!.capitalized
        
        cell.fullNameLabel.text = fullName
        if let url = object.avatar, url.count > 10 {
            cell.profileImageView.downloaded(from: URL(string: url)!, contentMode: .scaleAspectFit)
        } else {
            cell.profileImageView.image = UIImage(named: "user.png")
            }
        
        cell.removeButton.tag = indexPath.row
        
        return cell
    }
    
    func loadMyFriends() {
        guard let currentUserId = Helper.getUserDetails()?.id else {
            return
        }
        
        ApiClient.shared.getMyFriends(action: "friends", userId: currentUserId, limit: String(myFriendLimit), offset: String(myFriendSkip)) { (response:MyFriendCodable?, error) in
            if error != nil {
                return
            }
            
            
            DispatchQueue.main.async {
                self.tableView.beginUpdates()

                for (index, object) in response!.friends.enumerated() {
                    
                    let obj = MyFriendModel(id: object.id, user_id: object.user_id, friend_id: object.friend_id, date_created: object.date_created, friendID: object.friendID, email: object.email, firstName: object.firstName, lastName: object.lastName, birthday: object.birthday, gender: object.gender, cover: object.cover, avatar: object.avatar, bio: object.bio, allow_friends: object.allow_friends, allow_follow: object.allow_follow)
                    
                    self.myFriendResult.append(obj)
                    
                    self.friendshipStatus.append(3)
                    

                    let lastSectionIndex = self.tableView.numberOfSections - 1
                    let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                    let pathToLastRow = IndexPath(row: lastRowIndex + index, section: lastSectionIndex)
                    self.tableView.insertRows(at: [pathToLastRow], with: .automatic)

                }
                self.tableView.endUpdates()

                self.myFriendSkip += self.myFriendResult.count

            }
        }
    }

    fileprivate func updateFriendshipRequest(with action: String, userId:String, friendId:String, indexPathRow:Int) {
        
        if action == "reject" {
            ApiClient.shared.updateNotification(action: "insert", byUserId: userId, userId: friendId, type: "request") { (response:NotificationCodable?, error) in
                
            }
        } else if action == "delete" {
            ApiClient.shared.updateNotification(action: "delete", byUserId: userId, userId: friendId, type: "friend") { (response:NotificationCodable?, error) in
                
            }
        } else {
        ApiClient.shared.updateNotification(action: "insert", byUserId: userId, userId: friendId, type: "friend") { (response:NotificationCodable?, error) in
            
        }
        }
        
        
        ApiClient.shared.friendRequest(action: action, userId: userId, friendId: friendId) { (response:searchResponseCodable?, error) in
            if error != nil {
                DispatchQueue.main.async {
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
            }
            
            if response?.status == "200" {
                DispatchQueue.main.async {
//                    self.myFriendResult.remove(at: indexPathRow)
//                    let indexPath = IndexPath(row: indexPathRow, section: 0)
//                    self.tableView.beginUpdates()
//                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                    self.tableView.endUpdates()
                    //                                self.friendRequestCallback(self.friendshipStatus)
                }
            }
        }
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        if friendshipStatus[sender.tag] == 3 {
        Helper().showActionSheet(options: ["Delete"], isCancel: true, destructiveIndexes: [0], title: nil, message: nil, showIn: self) { (action) in
            if action == 0 {
                self.friendshipStatus.insert(0, at: sender.tag)
                sender.setTitle("Add", for: .normal)
                sender.setTitleColor(.white, for: .normal)
                sender.backgroundColor = Helper().facebookColor

                guard let currentUserId = Helper.getUserDetails()?.id else {
                           return
                       }
                
                let object = self.myFriendResult[sender.tag]
                

                self.updateFriendshipRequest(with: "delete", userId: currentUserId, friendId: String(object.friendID!), indexPathRow: sender.tag)
                self.updateFriendshipRequest(with: "delete", userId: String(object.friendID!), friendId: currentUserId, indexPathRow: sender.tag)

            }
        }
        } else if friendshipStatus[sender.tag] == 1 {
            self.friendshipStatus.insert(0, at: sender.tag)
            sender.setTitle("Add", for: .normal)
            
            guard let currentUserId = Helper.getUserDetails()?.id else {
                                  return
                              }
            let friendId = String(self.myFriendResult[sender.tag].friendID!)

            self.updateFriendshipRequest(with: "reject", userId: currentUserId, friendId: friendId, indexPathRow: sender.tag)
                       
        } else {
            self.friendshipStatus.insert(1, at: sender.tag)
            sender.setTitle("Cancel", for: .normal)
            
            
            guard let currentUserId = Helper.getUserDetails()?.id else {
                       return
                   }
            
            let friendId = String(self.myFriendResult[sender.tag].friendID!)
            self.updateFriendshipRequest(with: "add", userId: currentUserId, friendId: friendId, indexPathRow: sender.tag)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
            guard let indexpath = tableView.indexPathForSelectedRow else { return }
            let guest = segue.destination as! GuestVC
            guest.id = myFriendResult[indexpath.row].friendID!
            guest.firstName = (myFriendResult[indexpath.row]).firstName!
            guest.lastName = (myFriendResult[indexpath.row]).lastName!
            guest.avaPath = (myFriendResult[indexpath.row]).avatar ?? ""
            guest.coverPath = (myFriendResult[indexpath.row]).cover ?? ""
            guest.bio = (myFriendResult[indexpath.row]).bio ?? ""
        guest.friendshipStatus = friendshipStatus[indexpath.row]
            guest.allowFriends = (myFriendResult[indexpath.row]).allow_friends ?? 1
            guest.allowFollow = (myFriendResult[indexpath.row]).allow_follow ?? 1
//            guest.isfollowed = (requestResult?.requests?[indexpath.row])!.followed_user ?? 0
            guest.friendRequestCallback = { status in
//                self.getFriendRequests()
            }
        
        
        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
