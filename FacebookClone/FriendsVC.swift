//
//  FriendsVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 15/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

struct searchResponseCodable: Codable {
    let status: String
    let message: String?
    var users:[User]?
}

struct User:Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let birthday:String?
    let gender:String
    let cover: String?
    let avatar: String?
    let bio:String?
    let allow_friends: Int?
    let allow_follow: Int?
    let date_created: String
    let request_sender: Int?
    let request_receiver: Int?
    let friendship_sender: Int?
    let friendship_receiver: Int?
    
}

struct requestCodable: Codable {
    let status: String
    let message: String?
    var requests:[requestUser]?
}

struct requestUser:Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let birthday:String?
    let gender:String
    let cover: String?
    let avatar: String?
    let bio:String?
    let date_created: String
    let requested:Int?
}

class FriendsVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
                     #selector(FriendsVC.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    var searchLimit = 10
    var searchSkip = 0
    var isLoading = false
    var searchResult:searchResponseCodable?
    var friendshipStatus = [Int]()
    
    var requestResult:requestCodable?
    var requestedHeaders = ["FRIEND REQUESTS"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        searchTableView.rowHeight = UITableView.automaticDimension
//        searchTableView.estimatedRowHeight = 100
        friendsTableView.addSubview(refreshControl)
        createSearchBar()
        
        getFriendRequests()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        getFriendRequests()

    }
    
    func createSearchBar() {
        let searchBar = UISearchBar()
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        
        let searchBarTextField = searchBar.value(forKey: "searchField") as? UITextField
        searchBarTextField?.textColor = .white
        searchBarTextField?.tintColor = .white
        
        self.navigationItem.titleView = searchBar
    }

    fileprivate func getFriendRequests() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        isLoading = true
        guard let id = Helper.getUserDetails()?.id else {
            isLoading = false
            return
        }
        ApiClient.shared.getFriendRequests(action: "requests", id: String(id), offset: String(searchSkip), limit:String( searchLimit)) { (response:requestCodable?, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
            }
            
//            if response?.status == "200" {
                self.requestResult?.requests?.removeAll(keepingCapacity: false)
                
                if let _ = response?.requests {
                self.requestResult = response
                }
                
                DispatchQueue.main.async {
                    self.friendsTableView.reloadData()
                    self.isLoading = false
                }
//            }
        }
    }
    
    fileprivate func searchUsers(_ id: String, _ name: String) {
        ApiClient.shared.getFriends(action:"search", id: id, name: name, offset: String(searchSkip), limit: String(searchLimit)) { (response:searchResponseCodable?, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
            }
            
            if response?.status == "200" {
                self.searchResult?.users?.removeAll(keepingCapacity: false)
                self.friendshipStatus.removeAll(keepingCapacity: false)
                
                self.searchResult = response
                
                
                /*for user in self.searchResult!.users! {
                    if user.requested != nil {
                        self.friendshipStatus.append(1)
                    } else {
                        self.friendshipStatus.append(Int())
                    }
                }*/
                
                for user in self.searchResult!.users! {
                    //request sender is current user
                    if user.request_sender != nil && user.request_sender == Int(id) {
                        self.friendshipStatus.append(1)
                        
                        //request receiver is current user
                    } else if user.request_receiver != nil && user.request_receiver == Int(id) {
                        self.friendshipStatus.append(2)
                        
                        //current user sent friendship invitation, which got accepted
                    } else if user.friendship_sender != nil {
                        self.friendshipStatus.append(3)
                        
                        //current user accepeted the friendship invitation
                    } else if user.friendship_receiver != nil {
                        self.friendshipStatus.append(3)
                        
                        //all other case
                    } else {
                      self.friendshipStatus.append(0)
                    }
                }
                DispatchQueue.main.async {
                    self.searchTableView.isHidden = false
                    self.searchTableView.reloadData()
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isLoading = true
        guard let id = Helper.getUserDetails()?.id else {
            isLoading = false
            return
        }
        let name = searchBar.text!
        
        searchUsers(id, name)
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        searchTableView.isHidden = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        searchTableView.isHidden = true
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        self.searchResult?.users?.removeAll(keepingCapacity: false)
        self.friendshipStatus.removeAll(keepingCapacity: false)
        self.searchTableView.reloadData()
    }
    
    @IBAction func friendButtonActionForSearch(_ sender: UIButton) {
        guard let currentUseIid = Helper.getUserDetails()?.id, let friendUserId = searchResult?.users![sender.tag].id else { return }
        
       
        //current use didn't sent friend request -> send it
        if friendshipStatus[sender.tag] == 0 {
            
            self.friendshipStatus[sender.tag] = 1
            
//            button(with: sender, image: "request.png", tintColor: Helper().facebookColor)
            
            updateFriendshipRequest(action: "add", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
            
        }
        //current user sent friendship request -> cancel it
        else if friendshipStatus[sender.tag] == 1 {
            //update button
//            button(with: sender, image: "unfriend.png", tintColor: .darkGray)
            
            self.friendshipStatus[sender.tag] = 0
            //send request
            updateFriendshipRequest(action: "reject", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
           
        }
             //current user received friendship request -> accept/reject actionsheet
        else if friendshipStatus[sender.tag] == 2 {
            Helper().showActionSheet(options: ["Delete","Confirm"], isCancel: true, destructiveIndexes: [0], title: nil, message: nil, showIn: self) { (actionButtonIndex) in
                switch actionButtonIndex {
                case 0:
                    //udpate status -> no more any relations
                    self.friendshipStatus[sender.tag] = 0
//                    self.button(with: sender, image: "unfriend.png", tintColor: .darkGray)
                    self.updateFriendshipRequest(action: "reject", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
                    self.updateFriendshipRequest(action: "reject", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)

                case 1:
                    //update status -> now friends
                    self.friendshipStatus[sender.tag] = 3
//                    self.button(with: sender, image: "friend.png", tintColor: Helper().facebookColor)
                    self.updateFriendshipRequest(action: "confirm", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)

                default: break
                }
                
            }
            
        }
            //current user and searched user are friend -> show actionsheet
        else if friendshipStatus[sender.tag] == 3 {
            Helper().showActionSheet(options: ["Delete"], isCancel: true, destructiveIndexes: [0], title: nil, message: nil, showIn: self) { (actionButtonIndex) in
                switch actionButtonIndex {
                case 0:
                    self.friendshipStatus[sender.tag] = 0
//                    self.button(with: sender, image: "unfriend.png", tintColor: .darkGray)
                    self.updateFriendshipRequest(action: "delete", userId: currentUseIid, friendId: friendUserId, indexPathRow: sender.tag)
                    self.updateFriendshipRequest(action: "delete", userId: String(friendUserId), friendId: Int(currentUseIid)!, indexPathRow: sender.tag)


                default: break
                }
                
            }
            //show actionsheet to update friendship: delete
        }
        
    }
    
    func updateFriendshipRequest(action:String, userId:String, friendId:Int, indexPathRow:Int) {
        ApiClient.shared.friendRequest(action: action, userId: userId, friendId: String(friendId)) { (response:searchResponseCodable?, error) in
                    if error != nil {
                               DispatchQueue.main.async {
                                           Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                                    return
                                    }
                                }
                               
                    if response?.status == "200" {
                               DispatchQueue.main.async {
                                
                                if !self.searchTableView.isHidden {
                                self.searchTableView.beginUpdates()
                                self.searchTableView.reloadRows(at: [IndexPath(row: indexPathRow, section: 0)], with: .automatic)
                                self.searchTableView.endUpdates()
                                self.getFriendRequests()
                                }
                                
                               }
                    }
                }
    }
    
    func button(with button:UIButton, image:String, tintColor:UIColor) {
        let image = UIImage(named: image)
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = tintColor
    }
    
    func friendRequestAction(action:String, status:Int, cell:UITableViewCell) {
        guard let indexpath = friendsTableView.indexPath(for: cell) else { return }
            
        friendshipStatus.insert(status, at: indexpath.row)
        
        guard let friendId = Helper.getUserDetails()?.id, let userId = requestResult?.requests![indexpath.row].id else { return }
        updateFriendshipRequest(action: action, userId: String(userId), friendId: Int(friendId)!, indexPathRow: indexpath.row)
               
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GuestVC_searchTableView" {
            guard let indexpath = searchTableView.indexPathForSelectedRow else { return }
            let guest = segue.destination as! GuestVC
            guest.id = (searchResult?.users?[indexpath.row])!.id
            guest.firstName = (searchResult?.users?[indexpath.row])!.firstName
            guest.lastName = (searchResult?.users?[indexpath.row])!.lastName
            guest.avaPath = (searchResult?.users?[indexpath.row])!.avatar ?? ""
            guest.coverPath = (searchResult?.users?[indexpath.row])!.cover ?? ""
            guest.bio = (searchResult?.users?[indexpath.row])!.bio ?? ""
            guest.friendshipStatus = friendshipStatus[indexpath.row]
            guest.allowFriends = (searchResult?.users?[indexpath.row])!.allow_friends!
            guest.allowFollow = (searchResult?.users?[indexpath.row])!.allow_follow!
            guest.friendRequestCallback = { status in
                if status == 1 {
                    self.friendshipStatus.insert(1, at: indexpath.row)

                } else if status == 0 {
                    self.friendshipStatus.insert(Int(), at: indexpath.row)
                }
                self.searchTableView.beginUpdates()
                self.searchTableView.reloadRows(at: [IndexPath(row: indexpath.row, section: 0)], with: .automatic)
                self.searchTableView.endUpdates()
            }
        } else if segue.identifier == "GuestVC_friendTableView" {
            guard let indexpath = friendsTableView.indexPathForSelectedRow else { return }
            let guest = segue.destination as! GuestVC
            guest.id = (requestResult?.requests?[indexpath.row])!.id
            guest.firstName = (requestResult?.requests?[indexpath.row])!.firstName
            guest.lastName = (requestResult?.requests?[indexpath.row])!.lastName
            guest.avaPath = (requestResult?.requests?[indexpath.row])!.avatar ?? ""
            guest.coverPath = (requestResult?.requests?[indexpath.row])!.cover ?? ""
            guest.bio = (requestResult?.requests?[indexpath.row])!.bio ?? ""
            guest.friendshipStatus = friendshipStatus[indexpath.row] //request is received by current user
            guest.friendRequestCallback = { status in
                self.getFriendRequests()
            }
        }
        
        
    }
    
    
    
}

extension FriendsVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
        return (searchResult?.users?.count ?? 0)
        } else if tableView == friendsTableView {
            return (requestResult?.requests?.count ?? 0)
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchUserCell", for: indexPath) as! SearchUserCell
        
            cell.friendButton.tag = indexPath.row
            
        let user = searchResult?.users![indexPath.row]
        cell.fullNameLabel.text = "\(user?.firstName.capitalized ?? "") \(user?.lastName.capitalized ?? "")"
        
        if let url = user?.avatar, url.count > 10 {
            cell.profileImageView.downloaded(from: URL(string: url)!, contentMode: .scaleAspectFit)
        }
            //if other user
            if searchResult?.users![indexPath.row].allow_friends == 0 {
                cell.friendButton.isHidden = true
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.friendButton.isHidden = false
                cell.accessoryType = .none
            }
            
            if self.friendshipStatus[indexPath.row] == 1 {
                self.button(with: cell.friendButton, image: "request.png", tintColor: Helper().facebookColor)
                
            } else if self.friendshipStatus[indexPath.row] == 2 {
                self.button(with: cell.friendButton, image: "respond.png", tintColor: Helper().facebookColor)

            } else if self.friendshipStatus[indexPath.row] == 3 {
                self.button(with: cell.friendButton, image: "friends.png", tintColor: Helper().facebookColor)

            } else {
                self.button(with: cell.friendButton, image: "unfriend.png", tintColor: .darkGray)
            }
            
            
        return cell
        } else if tableView == friendsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! friendRequestCell
            
                cell.confirmButton.isHidden = false
                cell.deleteButton.isHidden = false
                cell.messageLabel.isHidden = true

                let user = requestResult?.requests![indexPath.row]
                cell.fullNameLabel.text = "\(user?.firstName.capitalized ?? "") \(user?.lastName.capitalized ?? "")"
            friendshipStatus.insert(2, at: indexPath.row)
                if let url = user?.avatar, url.count > 10 {
                    cell.profileImageView.downloaded(from: URL(string: url)!, contentMode: .scaleAspectFit)
                }
            
            cell.executeFriendRequest = friendRequestAction(action:status:cell:)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == friendsTableView {
            if requestResult?.requests != nil && section < (requestResult?.requests!.count)! {
                return requestedHeaders[section]
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        header.textLabel?.textColor = .darkGray
    }
}
