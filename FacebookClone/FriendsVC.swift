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
        guard let id = Helper.getUserDetails()?.id, let friendId = searchResult?.users![sender.tag].id else { return }
        
        var action = ""
        if friendshipStatus[sender.tag] == 1 {
        action = "reject"
        } else {
         action = "add"
        }
        ApiClient.shared.friendRequest(action: action, userId: id, friendId: String(friendId)) { (response:searchResponseCodable?, error) in
            if error != nil {
                       DispatchQueue.main.async {
                                   Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                            return
                            }
                        }
                       
            if response?.status == "200" {
                       DispatchQueue.main.async {
//                        Helper.showAlert(title: "Success", message: (response?.message)!, in: self)
                        
                        if self.friendshipStatus[sender.tag] == 1 {
                            self.friendshipStatus.insert(Int(), at: sender.tag)

                        } else {
                            self.friendshipStatus.insert(1, at: sender.tag)
                        }
                        self.searchTableView.beginUpdates()
                        self.searchTableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                        self.searchTableView.endUpdates()
                        
                       }
            }
        }
        }
    
    func friendRequestAction(action:String, cell:UITableViewCell) {
        guard let indexpath = friendsTableView.indexPath(for: cell) else { return }
        guard let friendId = Helper.getUserDetails()?.id, let userId = requestResult?.requests![indexpath.row].id else { return }
               
               ApiClient.shared.friendRequest(action: action, userId: String(userId), friendId: String(friendId)) { (response:requestCodable?, error) in
                   if error != nil {
                              DispatchQueue.main.async {
                               Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                               return
                                   }
                               }
                              
                   if response?.status == "200" {
                       DispatchQueue.main.async {
//                           self.requestResult?.requests?.remove(at: indexpath.row)
//                           self.friendsTableView.beginUpdates()
//                           self.friendsTableView.deleteRows(at: [indexpath], with: .automatic)
//                           self.friendsTableView.endUpdates()
                       }
                   }
               }
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
            guest.requested = friendshipStatus[indexpath.row]
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
            guest.requested = 2 //request is received by current user
            guest.friendRequestCallback = { status in
                self.getFriendRequests()
//                if status == 1 {
//                    self.requested.insert(1, at: indexpath.row)
//
//                } else {
//                    self.requested.insert(Int(), at: indexpath.row)
//                }
//                self.friendsTableView.beginUpdates()
//                self.friendsTableView.reloadRows(at: [IndexPath(row: indexpath.row, section: 0)], with: .automatic)
//                self.friendsTableView.endUpdates()
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
                
                if let url = user?.avatar, url.count > 10 {
                    cell.profileImageView.downloaded(from: URL(string: url)!, contentMode: .scaleAspectFit)
                }
            
            cell.executeFriendRequest = friendRequestAction(action:cell:)
            
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func button(with button:UIButton, image:String, tintColor:UIColor) {
        let image = UIImage(named: image)
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = tintColor
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
