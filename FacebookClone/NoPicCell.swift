//
//  NoPicCell.swift
//  FacebookClone
//
//  Created by Ravindra on 10/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class NoPicCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    
    var profileImageUrl: String? {
        didSet {
            URLSession(configuration: .default).dataTask(with: URL(string:profileImageUrl!)!) { (data, response, error) in
                if error != nil {
                    if let image = UIImage(named: "user.png") {
                        Global.postAvas.append(image)
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                        }
                    }
                }
                
                if let image = UIImage(data: data!) {
                    Global.postAvas.append(image)
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
                
            }.resume()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
