//
//  FriendsVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 15/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchTableView: UITableView!
    
    var limit = 10
    
    var skip = 0
    var isLoading = false
    
    struct FriendsCodable: Codable {
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
        let requested:Int?
    }
    
    var searchResult:FriendsCodable?
    
    var requested = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchTableView.rowHeight = UITableView.automaticDimension
        searchTableView.estimatedRowHeight = 100
        createSearchBar()
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

    fileprivate func loadUsers(_ id: String, _ name: String) {
        ApiClient.shared.getFriends(action:"search", id: id, name: name, offset: String(skip), limit: String(limit)) { (response:FriendsCodable?, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.isLoading = false
                    Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                    return
                }
            }
            
            if response?.status == "200" {
                self.searchResult?.users?.removeAll(keepingCapacity: false)
                self.requested.removeAll(keepingCapacity: false)
                
                self.searchResult = response
                
                
                for user in self.searchResult!.users! {
                    if user.requested != nil {
                        self.requested.append(1)
                    } else {
                        self.requested.append(Int())
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
        
        loadUsers(id, name)
        
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
        self.requested.removeAll(keepingCapacity: false)
        self.searchTableView.reloadData()
    }
    
    @IBAction func friendButtonAction(_ sender: UIButton) {
        guard let id = Helper.getUserDetails()?.id, let friendId = searchResult?.users![sender.tag].id else { return }
        
        var action = ""
        if requested[sender.tag] == 1 {
        action = "reject"
        } else {
         action = "add"
        }
        ApiClient.shared.friendRequest(action: action, userId: id, friendId: String(friendId)) { (response:FriendsCodable?, error) in
            if error != nil {
                       DispatchQueue.main.async {
                                   Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                            return
                            }
                        }
                       
            if response?.status == "200" {
                       DispatchQueue.main.async {
                        Helper.showAlert(title: "Success", message: (response?.message)!, in: self)
                        
                        if self.requested[sender.tag] == 1 {
                            self.requested.insert(Int(), at: sender.tag)

                        } else {
                            self.requested.insert(1, at: sender.tag)
                        }
                        self.searchTableView.beginUpdates()
                        self.searchTableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .automatic)
                        self.searchTableView.endUpdates()
                        
                       }
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexpath = searchTableView.indexPathForSelectedRow else { return }
        if segue.identifier == "GuestVC" {
            let guest = segue.destination as! GuestVC
            guest.id = (searchResult?.users?[indexpath.row])!.id
            guest.firstName = (searchResult?.users?[indexpath.row])!.firstName
            guest.lastName = (searchResult?.users?[indexpath.row])!.lastName
            guest.avaPath = (searchResult?.users?[indexpath.row])!.avatar ?? ""
            guest.coverPath = (searchResult?.users?[indexpath.row])!.cover ?? ""
            guest.bio = (searchResult?.users?[indexpath.row])!.bio ?? ""
        }
    }
    
}

extension FriendsVC:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
        return (searchResult?.users?.count ?? 0)
        } else {
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
            
            if self.requested[indexPath.row] == 1 {
                cell.friendButton.setImage(UIImage(named: "friend.png"), for: .normal)
                cell.friendButton.tintColor = Helper().facebookColor
            } else {
                cell.friendButton.setImage(UIImage(named: "unfriend.png"), for: .normal)
                cell.friendButton.tintColor = .darkGray
            }
        return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == searchTableView {
        return 100
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
