//
//  RecommendedFriendCell.swift
//  FacebookClone
//
//  Created by Ravi Rana on 05/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class RecommendedFriendCell: UITableViewCell {
    var executeFriendRecommendation = {(action:String, cell:UITableViewCell) ->Void in }

        @IBOutlet weak var deleteButton: UIButton!
       @IBOutlet weak var addfriendButton: UIButton!
       @IBOutlet weak var profileImageView: UIImageView!
       @IBOutlet weak var fullNameLabel: UILabel!
       @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   @IBAction func addFriendButtonAction(_ sender: UIButton) {
        addfriendButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false

        messageLabel.text = "Request sent."

        executeFriendRecommendation("add", self)
    }

    @IBAction func deleteButtonAction(_ sender: UIButton) {
        addfriendButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
        messageLabel.text = "Removed."
        
        executeFriendRecommendation("remove", self)
    }

}
