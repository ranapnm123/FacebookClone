//
//  RequestUserCell.swift
//  FacebookClone
//
//  Created by Ravindra on 20/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit



class friendRequestCell: UITableViewCell {
    var executeFriendRequest = {(action:String, cell:UITableViewCell) ->Void in }

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func confirmButtonAction(_ sender: UIButton) {
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
        messageLabel.text = "Request accepted."
        
        executeFriendRequest("confirm", self)
    }

    @IBAction func deleteButtonAction(_ sender: UIButton) {
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
        messageLabel.text = "Request removed."
        
        executeFriendRequest("delete", self)
    }
}
