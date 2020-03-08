//
//  NotificationsCell.swift
//  FacebookClone
//
//  Created by Ravi Rana on 07/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class NotificationsCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width/2
        iconImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
