//
//  CommentsVC.swift
//  FacebookClone
//
//  Created by Ravindra on 13/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController {

    struct commentsCodable: Codable {
        let id:Int?
        let post_id:Int?
        let user_id:Int?
        let comment:String?
        let date_created:String?
        let text:String?
        let picture:String?
        let firstName:String?
        let lastName:String?
        let avatar:String?
    }
    
    struct commentResponse: Codable {
        let comments:[commentsCodable]?
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentTextView_bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView_heightConstraint: NSLayoutConstraint!
    var commentsTextView_button_identity = CGFloat()
    
    var profileImage = UIImage()
    var fullNameString = String()
    var dateString = String()
    
    var textString = String()
    var pictureImage = UIImage()
    var postId = String()
    
    struct Mesasge {
        let name:String
        let profilePictureUrl:String
        let messagetext:String
        let commentId:Int
    }
    
    var comments = [Mesasge]()
    var skipForComments = 0
    var limitForComments = 10
    var postOwnerId = String()
    
    struct insertCommentCodable: Codable {
        let status: String
        let message: String
        let new_comment_id: Int
    }
    struct deleteCommentCodable: Codable {
        let status: String
        let message: String
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(true, animated: false)
        
        profileImageView.image = profileImage
        fullNameLabel.text = fullNameString
        dateLabel.text = Helper.formatDate(dateString:dateString)
        
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        textLabel.text = textString
        pictureImageView.image = pictureImage
        
        if pictureImage.size.width == 0 {
            pictureImageView.removeFromSuperview()
            containerView.frame.size.height -= pictureImageView.frame.size.height
        }
        
        commentTextView.layer.cornerRadius = 14
        
        commentsTextView_button_identity = commentTextView_bottomConstraint.constant
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        
        loadComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            commentTextView_bottomConstraint.constant += keyboardSize.height - 80
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        commentTextView_bottomConstraint.constant = commentsTextView_button_identity
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func insertComment() {
        if commentTextView.text.isEmpty == false && commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false  {
            sendComment()
        }
    }
    
    func sendComment() {
        guard let id = Helper.getUserDetails()?.id else { return}
               
               
               
               
               let action = "insert"
               
               let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
               
        //send comment notification to server
            ApiClient.shared.updateNotification(action: "insert", byUserId: id, userId: postOwnerId, type: "comment") { (response:NotificationCodable?, error) in
                
            }
        
               ApiClient.shared.insertComment(userId: id, postId: postId, action: action, comment: comment) { (response:insertCommentCodable?, error) in
                   
                if error != nil {
                   DispatchQueue.main.async {
                               Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                   }
                       return
                   }
                   DispatchQueue.main.async {
                   if response?.status == "200" {
                       
                       let fullName = "\(Helper.getUserDetails()?.firstName ?? "") \(Helper.getUserDetails()?.lastName ?? "")"
                       let message = Mesasge(name: fullName, profilePictureUrl: Helper.getUserDetails()?.avatar ?? "", messagetext: comment, commentId: response!.new_comment_id)
                       self.comments.append(message)
                       let indexpath = IndexPath(item: self.comments.count-1, section: 0)
                       self.tableView.beginUpdates()
                       self.tableView.insertRows(at: [indexpath], with: .top)
                       self.tableView.endUpdates()
                       
                       self.tableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
                       
                       self.commentTextView.text = ""
                       self.textViewDidChange(self.commentTextView)
                       self.commentTextView.resignFirstResponder()
                       
                   } else {
                       Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
                   }
                   }
               }
    }
    
    func loadComments() {
        ApiClient.shared.getPostComments(postId: postId, offset: String(skipForComments), limit: String(limitForComments), action: "select") { (response:commentResponse?, error) in
            
            if error != nil {
            DispatchQueue.main.async {
//                        Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
            }
                return
            }
            
            for object in (response?.comments)! {
                let fullName = "\(object.firstName!) \(object.lastName!)"

                let message = Mesasge(name: fullName, profilePictureUrl: object.avatar ?? "", messagetext: object.comment ?? "", commentId: object.id!)
                self.comments.append(message)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                let indexpath = IndexPath(row: self.comments.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexpath, at: .bottom, animated: true)
            }
            
        }
    }
    
    func deleteComment(indexpath:IndexPath) {
        guard let id = Helper.getUserDetails()?.id else { return}

        let message = comments[indexpath.row]
        
        //send comment notification to server
                   ApiClient.shared.updateNotification(action: "delete", byUserId: id, userId: postOwnerId, type: "comment") { (response:NotificationCodable?, error) in
                       
                   }
        
        ApiClient.shared.deleteComment(commentId: String(message.commentId), action: "delete") { (response:deleteCommentCodable?, error) in
            
            if error != nil {
            DispatchQueue.main.async {
                        Helper.showAlert(title: "Error", message: error!.localizedDescription, in: self)
            }
                return
            }
            
            self.comments.remove(at: indexpath.row)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexpath], with: .automatic)
                self.tableView.endUpdates()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.resignFirstResponder()
    }
}

extension CommentsVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // declaring new size of the textView. we increase the height
               let newSize = textView.sizeThatFits(CGSize.init(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
               
               // assign new size to the textView
               textView.frame.size = CGSize.init(width: CGFloat(fmaxf(Float(newSize.width), Float(textView.frame.width))), height: newSize.height)
               
               // resize the textView
               self.commentTextView_heightConstraint.constant = newSize.height

               //UIView.animate(withDuration: 0.2) {
                   self.view.layoutIfNeeded()
               //}
               
        
    }
}

extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        
        let message = comments[indexPath.row]
        
        cell.profileImageView.downloaded(from: message.profilePictureUrl, contentMode: .scaleAspectFit)
        cell.fullNameLabel.text = message.name
        cell.commentLabel.text = message.messagetext
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteComment(indexpath: indexPath)
        }
    }
    
}
