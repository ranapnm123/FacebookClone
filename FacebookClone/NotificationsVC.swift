//
//  NotificationsVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 07/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class NotificationsVC: UITableViewController {

    struct NotificationCodable:Codable {
        let status: String?
        let message: String?
        var notifications:[NotificationParams]?
    }
    
    struct NotificationParams:Codable {
        let email: String
        let firstName: String
        let lastName: String
        let birthday:String?
        let gender:String
        let cover: String?
        let avatar: String?
        let bio:String?
        let notifId:Int?
        let notifByUserId: Int?
        let notifUserId: Int?
        let notifType: String?
        let notifViewed: String?
        let notifDateCreated: String?
        
        enum CodingKeys: String, CodingKey {
            case email = "email"
            case firstName = "firstName"
            case lastName = "lastName"
            case birthday = "birthday"
            case gender = "gender"
            case cover = "cover"
            case avatar = "avatar"
            case bio = "bio"
            case notifId = "id"
            case notifByUserId = "byUser_id"
            case notifUserId = "user_id"
            case notifType = "type"
            case notifViewed = "viewed"
            case notifDateCreated = "date_created"
        }
    }
    
    struct Notification {
        let email: String
        let firstName: String
        let lastName: String
        let birthday:String?
        let gender:String
        let cover: String?
        let avatar: String?
        let bio:String?
        let notifId:Int?
        let notifByUserId: Int?
        let notifUserId: Int?
        let notifType: String?
        let notifViewed: String?
        let notifDateCreated: String?
    }
    
    
    var notifSkip = 0
    var notifLimit = 6
    var isLoading = false
    var notifResult = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
       
        loadNotifications(offset: notifSkip, limit: notifLimit)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifResult.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationsCell
        
        let object = self.notifResult[indexPath.row]
        
        if object.notifViewed == "yes" {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = Helper().facebookColor.withAlphaComponent(0.15)
        }
        
        let fName = object.firstName
        let lName = object.lastName
        let fullName = fName.capitalized + " " + lName.capitalized
        
        var message = ""
        
        switch object.notifType {
        case "friend":
            message = " now is your friend."
            cell.iconImageView.image = UIImage(named: "notifications_friend")
        case "follow":
            message = " has started following you."
            cell.iconImageView.image = UIImage(named: "notifications_follow")
        case "like":
            message = " liked your post."
            cell.iconImageView.image = UIImage(named: "notifications_like")
        case "comment":
            message = " has commented on your post."
            cell.iconImageView.image = UIImage(named: "notifications_comment")
        case "avatar":
            message = " has changed profile picture."
            cell.iconImageView.image = UIImage(named: "notifications_ava")
        case "cover":
            message = " has changed cover picture."
            cell.iconImageView.image = UIImage(named: "notifications_cover")
        case "bio":
            message = " has changed bio."
            cell.iconImageView.image = UIImage(named: "notifications_bio")
        default:
            message = ""
        }
        
        let boldString = NSMutableAttributedString(string: fullName, attributes: [kCTFontAttributeName as NSMutableAttributedString.Key: UIFont.boldSystemFont(ofSize: 17)])
        let regularString = NSMutableAttributedString(string: message)
        boldString.append(regularString)
        
        cell.messageLabel.attributedText = boldString
        
        if (object.avatar!.count) > 10 {
            cell.profileImageView.downloaded(from: URL(string: object.avatar!)!, contentMode: .scaleAspectFit)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionSheet(indexpath: indexPath)
    }
   
    func showActionSheet(indexpath:IndexPath){
        Helper().showActionSheet(options: ["Hide"], isCancel: true, destructiveIndexes: [3], title: nil, message: nil, showIn: self) { (action) in
            if action == 0 {
                let object = self.notifResult[indexpath.row]
                ApiClient.shared.updateNotificationViewed(action: "update", byUserId: "0", userId: "0", viewed: "ignored", notifId: String(object.notifId!), type: object.notifType!) { (response:NotificationCodable?, error) in
                    DispatchQueue.main.async {
                        self.notifResult.remove(at: indexpath.row)
                        
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexpath], with: .automatic)
                        self.tableView.endUpdates()
                        
                        
                    }
            }
        }
    }
    }
    
    func loadNotifications(offset:Int, limit:Int) {
        isLoading = true
        guard let currentuserId = Helper.getUserDetails()?.id else {
            return
        }
        
        ApiClient.shared.getNotification(action: "select", byUserId: currentuserId, userId: currentuserId, type: "", offset: String(offset), limit: String(limit)) { (response:NotificationCodable?, error) in
            self.isLoading = false
            if error != nil {
                return
            }
            
            if response?.status == "200" {
                DispatchQueue.main.async {
                self.tableView.beginUpdates()
                    for (index, object) in (response?.notifications!.enumerated())! {
                    let val = Notification(email: object.email,
                                           firstName: object.firstName,
                                           lastName: object.lastName,
                                           birthday: object.birthday,
                                           gender: object.gender,
                                           cover: object.cover,
                                           avatar: object.avatar,
                                           bio: object.avatar,
                                           notifId: object.notifId,
                                           notifByUserId: object.notifByUserId,
                                           notifUserId: object.notifUserId,
                                           notifType: object.notifType,
                                           notifViewed: object.notifViewed,
                                           notifDateCreated: object.notifDateCreated)
                    
                                self.notifResult.append(val)
                    
                               let lastSectionIndex = self.tableView.numberOfSections - 1
                               let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                               let pathToLastRow = IndexPath(row: lastRowIndex + index, section: lastSectionIndex)
                               self.tableView.insertRows(at: [pathToLastRow], with: .automatic)
                           
                        ApiClient.shared.updateNotificationViewed(action: "update", byUserId: "0", userId: "0", viewed: "yes", notifId: String(object.notifId!), type: object.notifType!) { (response:NotificationCodable?, error) in
                            
                        }
                    }
                    self.tableView.endUpdates()
                    self.notifSkip += self.notifResult.count
                }
                
                
                
            }
        }
    }
    

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableVeiwH = tableView.contentOffset.y - tableView.contentSize.height + 60
        if tableVeiwH > -tableView.frame.height && isLoading == false {
            loadNotifications(offset: notifSkip, limit: notifLimit)
        }
    }
}
