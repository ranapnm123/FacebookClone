//
//  BioVC.swift
//  FacebookClone
//
//  Created by Ravindra on 31/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class BioVC: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var bioTexView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadUser() {
           guard let firstName = Helper.getUserDetails()?.firstName,
           let lastName = Helper.getUserDetails()?.lastName,
            let avatarImageUrl = Helper.getUserDetails()?.avatar,
           let bio = Helper.getUserDetails()?.bio else { return }
           
           fullNameLabel.text = "\(firstName) \(lastName)".capitalized
          
        Helper.downloadImage(path: avatarImageUrl, showIn: self.profileImageView, placeholderImage: "user.jpg")

          
       }
}
