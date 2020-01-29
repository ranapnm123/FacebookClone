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
    
    class func instantiateViewController(identifier:String, animated:Bool, by vc:UIViewController, completion:(() -> Void)?) {
        let viewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: identifier)
        viewController.modalPresentationStyle = .fullScreen
        vc.present(viewController, animated: animated, completion: completion)
    }
    
    class func saveUserDetails(object:LoginResponse) {
    let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
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
    
   // MIME for the Image
    class func body(with parameters: [String: Any]?, filename: String, filePathKey: String?, imageDataKey: Data, boundary: String) -> NSData {
        
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
        
        body.append(imageDataKey)
        body.append(Data("\r\n".utf8))
        body.append(Data("--\(boundary)--\r\n".utf8))
        
        return body
    }
}
