//
//  PicCell.swift
//  FacebookClone
//
//  Created by Ravindra on 10/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class PicCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var pictureImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    var profileImageUrl: String? {
           didSet {
            if profileImageUrl!.count > 0 {
               URLSession(configuration: .default).dataTask(with: URL(string:profileImageUrl ?? " ")!) { (data, response, error) in
                   if error != nil {
                       if let image = UIImage(named: "user.png") {
                           Global.postAvas.append(image)
                           DispatchQueue.main.async {
                               self.profileImageView.image = image
                           }
                       }
                    return
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
       }
    
    var postPictureUrl: String? {
        didSet {
            URLSession(configuration: .default).dataTask(with: URL(string:postPictureUrl!)!) { (data, response, error) in
                if error != nil {
                    if let image = UIImage(named: "user.png") {
                        Global.postPicture.append(image)
                        DispatchQueue.main.async {
                            self.postImageView.image = image
                        }
                    }
                    return
                }
                
                if let data = data {
                if let image = UIImage(data: data) {
                    Global.postPicture.append(image)
                    DispatchQueue.main.async {
                        self.postImageView.image = image
                    }
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
