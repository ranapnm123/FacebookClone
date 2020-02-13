//
//  Helper.swift
//  FaceBookClone
//
//  Created by Ravi Rana on 21/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

let currentUserDetails = "currentUserDetails"
class Helper {
    
    
    // validate email address function / logic
    func isValid(email: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: email)
        
        return result
    }
    
    
    // validate name function / logic
    func isValid(name: String) -> Bool {
        
        // declaring the rule of regular expression (chars to be used). Applying the rele to current state. Verifying the result (email = rule)
        let regex = "[A-Za-z]{2,}"
        let test = NSPredicate(format: "SELF MATCHES %@", regex)
        let result = test.evaluate(with: name)
        
        return result
    }
    
    class func showAlert(title:String, message:String, in vc:UIViewController) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(ok)
        vc.present(alert, animated: true, completion: nil)
    }
    
    class func instantiateViewController(identifier:String, animated:Bool, modalStyle:UIModalPresentationStyle, by vc:UIViewController, completion:(() -> Void)?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: identifier)
        viewController.modalPresentationStyle = modalStyle
        vc.present(viewController, animated: animated, completion: completion)
    }
    
    class func saveUserDetails(object: LoginResponse, password:String?) {
        let temp = LoginResponse(status: object.status, message: object.message, email: object.email, password: password, firstName: object.firstName, lastName: object.lastName, birthday: object.birthday, gender: object.gender, id: object.id, cover: object.cover, avatar: object.avatar, bio: object.bio)
        
    let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(temp) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: currentUserDetails)
    }
    }
    
    class func getUserDetails() -> LoginResponse? {
        let defaults = UserDefaults.standard
    if let savedPerson = defaults.object(forKey: currentUserDetails) as? Data {
        let decoder = JSONDecoder()
        if let loadedPerson = try? decoder.decode(LoginResponse.self, from: savedPerson) {
            return loadedPerson
        }
    }
        return nil
    }
    
    class func loadFullname(firstName: String, lastName:String, showIn label:UILabel) {
        label.text = "\(firstName.capitalized) \(lastName.capitalized)"
    }
    
   // MIME for the Image
    class func body(with parameters: [String: Any]?, filename: String, filePathKey: String?, imageDataKey: Data?, boundary: String) -> NSData {
        
        let body = NSMutableData()
        
        // MIME Type for Parameters [id: 777, name: michael]
        if parameters != nil {
            for (key, value) in parameters! {
                body.append(Data("--\(boundary)\r\n".utf8))
                body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
                body.append(Data("\(value)\r\n".utf8))
            }
        }
        
        
        // MIME Type for Image
        let mimetype = "image/jpg"
        
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimetype)\r\n\r\n".utf8))
        
        if imageDataKey != nil {
        body.append(imageDataKey!)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        }
        return body
    }
    
    class func downloadImage(path:String, showIn imageView:UIImageView, placeholderImage:String) {
        if String(describing: path).isEmpty == false {
                   DispatchQueue.main.async {
                       
                   if let url = URL(string: path ) {
                       
                       guard let data = try? Data(contentsOf: url) else { return }
                       
                       guard let image = UIImage(data: data) else {
                           imageView.image = UIImage(named: placeholderImage)
                           return }
                       
                       imageView.image = image

                       }
                   }
               }
    }

    class func downloadImageFromUrl(path:String, showIn imageView:UIImageView, completion:@escaping((Bool) -> Void)) {
           URLSession(configuration: .default).dataTask(with: URL(string: path)!) { (data, response, error) in
               
               if error != nil {
                   return
               }
               
               if let image = UIImage(data: data!) {
                   DispatchQueue.main.async {
                       imageView.image = image
                   }
               }
               
               
           }
       }
    
    class func formatDate(dateString:String) -> String {
        let formatterGetter = DateFormatter()
        formatterGetter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatterGetter.date(from: dateString)
        
        let formatterSetter = DateFormatter()
        formatterSetter.dateFormat = "MMMM dd yyyy HH:mm"
        let dateString = formatterSetter.string(from: date!)
        
        return dateString
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
    
    
    
}
