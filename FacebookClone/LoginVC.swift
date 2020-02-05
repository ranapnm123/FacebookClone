//
//  LoginVC.swift
//  FaceBookClone
//
//  Created by Ravi Rana on 21/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

//codable
struct LoginResponse : Codable
{
    let status : String
    let message : String
    let email : String?
    let firstName : String?
    let lastName : String?
    let birthday : String?
    let gender : String?
    let id : String?
    let cover: String?
    let avatar: String?
    let bio: String?
}

class LoginVC: UIViewController {
    
    
    
    // ui obj
    @IBOutlet weak var textFieldsView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var loginButton: UIButton!
 
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var rightLineView: UIView!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var handsImageView: UIImageView!
    
    
    // constraints obj
    @IBOutlet weak var coverImageView_top: NSLayoutConstraint!
    @IBOutlet weak var whiteIconImageView_y: NSLayoutConstraint!
    @IBOutlet weak var handsImageView_top: NSLayoutConstraint!
    @IBOutlet weak var registerButton_bottom: NSLayoutConstraint!
    
    
    
    // executed when the scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // declaring notification observation in order to catch UIKeyboardWillShow / UIKeyboardWillHide Notification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Helper.getUserDetails()?.id != nil {
                                                 Helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)

        }
    }
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    
    // executed once the keyboard is about to be shown
    @objc func keyboardWillShow(notification: Notification) {
        
        // deducting 75pxls from current Y position (doesn't act till forced)
        coverImageView_top.constant -= 75
        handsImageView_top.constant -= 75
        whiteIconImageView_y.constant += 50
        
        // if iOS (app) is able to access keyboard's frame, then change Y position of the Register Button
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            registerButton_bottom.constant += keyboardSize.height
        }
        
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
            
            self.handsImageView.alpha = 0
            
            // force to update the layout
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    // executed once the keyboard is about to be hidden
    @objc func keyboardWillHide(notification: Notification) {
        
        // adding 75pxls from current Y position (doesn't act till forced)
        coverImageView_top.constant += 75
        handsImageView_top.constant += 75
        whiteIconImageView_y.constant -= 50
        
        // if iOS (app) is able to access keyboard's frame, then change Y position of the Register Button
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            registerButton_bottom.constant -= keyboardSize.height
        }
        
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
            
            self.handsImageView.alpha = 1
            
            // force to update the layout
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    
    // executed after aligning the objects
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // calling configure functions to be executed, as they're already declared
        configure_textFieldsView()
        configure_loginBtn()
        configre_orLabel()
        configre_registerButton()
        
    }
    
    
    // this func stores code which configures appearance of the textFields' View
    func configure_textFieldsView() {
        
        // declaring constants to store information which later on will be assigned to certain 'object'
        let width = CGFloat(2)
        let color = UIColor.systemGroupedBackground.cgColor
        
        // creating layer to be a border of the view
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        // creating layer to be a line in the center of the view
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - width, width: textFieldsView.frame.width, height: width)
        
        // assigning created layers to the view
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        
        // rounded corners
        textFieldsView.layer.cornerRadius = 5
        textFieldsView.layer.masksToBounds = true
        
    }
    
    
    // will configure Login button's appearance
    func configure_loginBtn() {
        
        loginButton.layer.cornerRadius = 5
        loginButton.layer.masksToBounds = true
        //loginButton.isEnabled = false
        
    }
    
    
    // will configure appearance of OR label and its views storing the lines
    func configre_orLabel() {
        
        // shortcuts
        let width = CGFloat(2)
        let color = UIColor.systemGroupedBackground.cgColor
        
        // create Left Line object (layer), by assigning width and color values (constants)
        let leftLine = CALayer()
        leftLine.borderWidth = width
        leftLine.borderColor = color
        leftLine.frame = CGRect(x: 0, y: leftLineView.frame.height / 2 - width, width: leftLineView.frame.width, height: width)
        
        // create Right Line object (layer), by assingning width and color values declared above (for shorter way)
        let rightLine = CALayer()
        rightLine.borderWidth = width
        rightLine.borderColor = color
        rightLine.frame = CGRect(x: 0, y: rightLineView.frame.height / 2 - width, width: rightLineView.frame.width, height: width)
        
        // assign lines (layer objects) to the UI obj (views)
        leftLineView.layer.addSublayer(leftLine)
        rightLineView.layer.addSublayer(rightLine)
        
    }
    
    
    // will configre appearance of Register Button
    func configre_registerButton() {
        
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
        border.borderColor = UIColor(red: 68/255, green: 105/255, blue: 176/255, alpha: 1).cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: registerButton.frame.width, height: registerButton.frame.height)
        
        // assign border to the obj (button)
        registerButton.layer.addSublayer(border)
        
        // rounded corner
        registerButton.layer.cornerRadius = 5
        registerButton.layer.masksToBounds = true
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if let email = emailTextField.text,let password = passwordTextField.text {
        ApiClient.shared.loginUser(email: email,
                                      password: password) { (response:LoginResponse?, error:Error?) in
                                        if error != nil {
                                            print(response!)
                                            return
                                        }
                                        
                                                                              DispatchQueue.main.async {
                                        if response?.status == "200" {
                                            
                                            Helper.saveUserDetails(object: response!)
                                            
                                            Helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)

                                        } else {
                                            Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                                            }
                                            
                                        }

        }
    }
    }


}








