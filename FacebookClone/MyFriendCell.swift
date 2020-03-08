//
//  MyFriendCell.swift
//  FacebookClone
//
//  Created by Ravi Rana on 08/03/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class MyFriendCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
