//
//  EditVC.swift
//  FacebookClone
//
//  Created by Ravi Rana on 08/02/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

class EditVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var addBio: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var birthDayTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    
    var datePicker: UIDatePicker!
    var genderPicker: UIPickerView!
    let genderValues = ["Female", "Male"]

    enum imageViewTapped: String {
        case cover = "cover"
        case avatar = "avatar"
    }
    
    var imagViewType:String?
    var isCoverAva:Bool?
    var isProfileAva:Bool?
    var isPasswordChanged:Bool = false
    var isCoverImageChanged:Bool = false
    var isProfileImageChanged:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureProfileImageView()
        loadUser()
        
        
        createDatePicker()
        createGenderPicker()
        
        bioAddedCallback = { bio in
                   if bio.isEmpty {
                      
                       
                   } else {
                       
                   }
               }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configreAddBioButton()
    }
    
    func configureProfileImageView() {
              let layer = CALayer()
              layer.borderWidth = 5
              layer.borderColor = UIColor.white.cgColor
              layer.frame = CGRect(x: 0, y: 0, width: profileImageView.frame.width, height: profileImageView.frame.height)
              profileImageView.layer.addSublayer(layer)
              
              profileImageView.layer.cornerRadius = 10
              profileImageView.clipsToBounds = true
          }
    
    func configreAddBioButton() {
           
           // creating constant named 'border' of type layer which acts as a border frame
           let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
           border.borderWidth = 2
           border.frame = CGRect(x: 0, y: 0, width: addBio.frame.width, height: addBio.frame.height)
           
           // assign border to the obj (button)
           addBio.layer.addSublayer(border)
           
           // rounded corner
           addBio.layer.cornerRadius = 5
           addBio.layer.masksToBounds = true
        
           
       }
    
    func loadUser() {
        guard let firstName = Helper.getUserDetails()?.firstName,
        let lastName = Helper.getUserDetails()?.lastName,
        let coverImageUrl = Helper.getUserDetails()?.cover,
        let avatarImageUrl = Helper.getUserDetails()?.avatar,
        let email = Helper.getUserDetails()?.email,
        let birthday = Helper.getUserDetails()?.birthday,
        let gender = Helper.getUserDetails()?.gender,
        let pass = Helper.getUserDetails()?.password
        else { return }
        
        firstNameTF.text = firstName.capitalized
        lastNameTF.text = lastName.capitalized
        emailTF.text = email
        passTF.text = pass
        
        if coverImageUrl.count > 10 {
            isCoverAva = true
        } else {
            self.coverImageView.image = UIImage(named: "homeCover.jpg")
            isCoverAva = false
        }
        Helper.downloadImage(path: coverImageUrl, showIn: self.coverImageView, placeholderImage: "HomeCover.jpg")
        
        if avatarImageUrl.count > 10 {
            isProfileAva = true
        } else {
            self.coverImageView.image = UIImage(named: "user.png")
            isProfileAva = false
        }
        Helper.downloadImage(path: avatarImageUrl, showIn: self.profileImageView, placeholderImage: "user.png")
        
        
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
//        let date = dateFormatterGet.date(from: birthday)
//        
//        let dateFormatterShow = DateFormatter()
//        dateFormatterShow.dateFormat = "MM dd, yyyy"
        birthDayTF.text = birthday//dateFormatterShow.string(from: date!)
        
        if gender == "1" {
            genderTF.text = "Female"
        } else {
            genderTF.text = "Male"
        }
       
    }
    
    fileprivate func createDatePicker() {
           // creating, configuring and implementing datePicker into BirthdayTextField
           datePicker = UIDatePicker()
           datePicker.datePickerMode = .date
           datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
           datePicker.addTarget(self, action: #selector(self.datePickerDidChange(_:)), for: .valueChanged)
           birthDayTF.inputView = datePicker
       }
    fileprivate func createGenderPicker() {
            genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderTF.inputView = genderPicker
    }
    
   // func will be executed whenever any date is selected
   @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
       
       // declaring the format to be used in TextField while presenting the date
       let formatter = DateFormatter()
       formatter.dateStyle = DateFormatter.Style.medium
       birthDayTF.text = formatter.string(from: datePicker.date)
       
       // declaring the format of date, then to place a dummy date into this format
       let compareDateFormatter = DateFormatter()
       compareDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
       let compareDate = compareDateFormatter.date(from: "2013/01/01 00:01")
       
       
   }
       
       func showPicker(with source: UIImagePickerController.SourceType) {
           
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.allowsEditing = true
           picker.sourceType = source
           present(picker, animated: true, completion: nil)
       }
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
           dismiss(animated: true) {
               switch self.imagViewType {
                
               case imageViewTapped.cover.rawValue :
                   self.coverImageView.image = image
                   self.isCoverAva = true
                   self.isCoverImageChanged = true
                
               case imageViewTapped.avatar.rawValue :
                   self.profileImageView.image = image
                   self.isProfileAva = true
                   self.isProfileImageChanged = true
                
               default: break
               }
           }
       }

       @IBAction func tapCoverAction(_ sender: UITapGestureRecognizer) {
           imagViewType = imageViewTapped.cover.rawValue
           showActionSheet()
       }
       
       @IBAction func tapUserAction(_ sender: UITapGestureRecognizer) {
       imagViewType = imageViewTapped.avatar.rawValue
       showActionSheet()
       }
       
       func showActionSheet() {
           let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
           let camera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
               if UIImagePickerController.isSourceTypeAvailable(.camera) {
                   self.showPicker(with: .camera)
               }
           }
           let photoLibrary = UIAlertAction.init(title: "Library", style: .default) { (action) in
               if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                   self.showPicker(with: .photoLibrary)
               }
           }
           let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
           let delete = UIAlertAction.init(title: "Delete", style: .destructive) { (action) in
               switch self.imagViewType {
               case imageViewTapped.cover.rawValue :
                   self.coverImageView.image = #imageLiteral(resourceName: "HomeCover")
                   self.isCoverAva = false
                   self.isCoverImageChanged = true
               case imageViewTapped.avatar.rawValue :
                   self.profileImageView.image = #imageLiteral(resourceName: "user")
                   self.isProfileAva = false
                   self.isProfileImageChanged = true
               default: break
               }
           }
           actionSheet.addAction(camera)
           actionSheet.addAction(photoLibrary)
           actionSheet.addAction(cancel)
           actionSheet.addAction(delete)
           
           switch self.imagViewType {
           case imageViewTapped.cover.rawValue :
               
               if self.isCoverAva == true {
                   delete.isEnabled = true
               } else {
                   delete.isEnabled = false
               }
           case imageViewTapped.avatar.rawValue :
               
               if self.isProfileAva == true {
                   delete.isEnabled = true
               } else {
                   delete.isEnabled = false
               }
           default: break
           }
           
           present(actionSheet, animated: true, completion: nil)
           
       }
       
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addBioAction(_ sender: Any) {
         Helper.instantiateViewController(identifier: "BioVC", animated: true, modalStyle: .overCurrentContext, by: self, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        updateUser()
        
        if self.isCoverImageChanged  == true && self.isProfileImageChanged == false  {
            self.uploadImage(from: self.coverImageView, type: imageViewTapped.cover.rawValue, completion: {
                print("cover image updated successfully")
            })
        }
        
        else if self.isProfileImageChanged == true && self.isCoverImageChanged == false {
            self.uploadImage(from: self.profileImageView, type: imageViewTapped.avatar.rawValue, completion: {
                 print("profile image updated successfully")
            })
        }
        
        else if self.isCoverImageChanged == true && self.isProfileImageChanged == true {
            self.uploadImage(from: self.coverImageView, type: imageViewTapped.cover.rawValue, completion: {
                 print("cover image updated successfully")
                self.uploadImage(from: self.profileImageView, type: imageViewTapped.avatar.rawValue, completion: {
                    print("profile image updated successfully")
                })
            })
        }
    }
    
    func uploadImage(from imageView:UIImageView, type:String, completion:@escaping() -> Void) {
       
          guard let id = Helper.getUserDetails()?.id else { return }
          
          
          ApiClient.shared.uploadImage(id: id, type: type, image: imageView.image!, fileName: type) { (response: LoginResponse?, error) in
          if error != nil {
             
                     return
                 }
            print("uploadImage == \(response!)");
               DispatchQueue.main.async {
                 if response?.status == "200" {
                     
                  Helper.saveUserDetails(object: response!, password: Helper.getUserDetails()?.password)
                  profileUpdateCallback()
                    completion()

                 } else {
                     Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                     }
                     
                 }
          }
          
      }
    
    func updateUser() {
        guard let id = Helper.getUserDetails()?.id else {
            return
        }
        let email = emailTF.text!
        let firstName = firstNameTF.text!
        let lastName = lastNameTF.text!
        let birthday = birthDayTF.text!
        var genderTemp = ""
        if genderTF.text == "Female" {
            genderTemp = "1"
        } else {
            genderTemp = "2"
        }
        let gender = genderTemp
        let password = passTF.text!
        
        let helper = Helper()
        // check email validation
        if helper.isValid(email: email) == false {
            
        } else if helper.isValid(name: firstName) == false {
        
        } else if helper.isValid(name: lastName) == false {
            
        } else if password.count < 6 {
            
        } else {
            
                ApiClient.shared.updateUser(id: id, email: email, password: password, isPass: isPasswordChanged.description, fname: firstName, lName: lastName, birthday: birthday, gender: gender) { (response:LoginResponse?, error) in
                DispatchQueue.main.async {
                           if error != nil {
                               Helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                                               return
                                           }
                                         
                                           if response?.status == "200" {
                                            print("updateUser == \(response!)")
                                            Helper.saveUserDetails(object: response!, password: password)
                                        profileUpdateCallback()
                                          Helper.showAlert(title: "Success", message: (response?.message)!, in: self)

                                           } else {
                                               Helper.showAlert(title: "Error", message: (response?.message)!, in: self)
                                               }
                                               
                    }
            }
            
        }
        
    }
    
    // called everytime when textField gets changed
       @IBAction func textFieldDidChange(_ textField: UITextField) {
           
        if textField == passTF {
            isPasswordChanged = true
        }
        }
       
       
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderValues.count
    }
   
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTF.text = genderValues[row]
        genderTF.resignFirstResponder()
    }
}
