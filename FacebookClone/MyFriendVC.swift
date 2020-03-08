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
    
    var myFriends = MyFriendCodable(status: nil, message: nil, friends: [])
    var myFriendSkip = 0
    var myFriendLimit = 3
    
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
        return myFriends.friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendCell", for: indexPath) as! MyFriendCell

        let object = self.myFriends.friends[indexPath.row]
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
            
            self.myFriends.friends.append(contentsOf: (response?.friends)!)
            
            DispatchQueue.main.async {

                for (index, _) in self.myFriends.friends.enumerated() {
                    self.tableView.beginUpdates()

                    let lastSectionIndex = self.tableView.numberOfSections - 1
                    let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                    let pathToLastRow = IndexPath(row: lastRowIndex + index, section: lastSectionIndex)
                    self.tableView.insertRows(at: [pathToLastRow], with: .automatic)
                    self.tableView.endUpdates()

                }
                
                self.myFriendSkip += self.myFriends.friends.count

            }
        }
    }

    @IBAction func removeButtonAction(_ sender: UIButton) {
        guard let currentUserId = Helper.getUserDetails()?.id else {
                   return
               }
        
        let object = self.myFriends.friends[sender.tag]
        
        var friendId = ""
        var userId = ""
        if  String(object.friend_id!) == currentUserId {
            friendId = currentUserId
            userId = String(object.user_id!)
        } else {
            friendId = String(object.friend_id!)
            userId = currentUserId
        }
//        var friendId = String(object.friend_id!) == currentUserId ? String(object.user_id!) : String(object.friend_id!)
        
        ApiClient.shared.friendRequest(action: "delete", userId: userId, friendId: friendId) { (response:searchResponseCodable?, error) in
                    if error != nil {
                               DispatchQueue.main.async {
                                           Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                                    return
                                    }
                                }
                               
                    if response?.status == "200" {
                               DispatchQueue.main.async {
                                self.myFriends.friends.remove(at: sender.tag)
                                let indexPath = IndexPath(row: sender.tag, section: 0)
                                self.tableView.beginUpdates()
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                self.tableView.endUpdates()
//                                self.friendRequestCallback(self.friendshipStatus)
                               }
                    }
                }

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let currentUserId = Helper.getUserDetails()?.id else {
            return
        }
        
            guard let indexpath = tableView.indexPathForSelectedRow else { return }
            let guest = segue.destination as! GuestVC
        guest.id = String((myFriends.friends[indexpath.row]).friend_id!) == currentUserId ? (myFriends.friends[indexpath.row]).user_id! : (myFriends.friends[indexpath.row]).friend_id!
            guest.firstName = (myFriends.friends[indexpath.row]).firstName!
            guest.lastName = (myFriends.friends[indexpath.row]).lastName!
            guest.avaPath = (myFriends.friends[indexpath.row]).avatar ?? ""
            guest.coverPath = (myFriends.friends[indexpath.row]).cover ?? ""
            guest.bio = (myFriends.friends[indexpath.row]).bio ?? ""
            guest.friendshipStatus = 3
            guest.allowFriends = (myFriends.friends[indexpath.row]).allow_friends ?? 1
            guest.allowFollow = (myFriends.friends[indexpath.row]).allow_follow ?? 1
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
