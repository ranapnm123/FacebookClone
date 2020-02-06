//
//  ApiClient.swift
//  FacebookClone
//
//  Created by Ravindra on 27/01/20.
//  Copyright © 2020 Ravi Rana. All rights reserved.
//

import UIKit

let baseUrl = "http://localhost/fb"
class ApiClient {

    static var shared = ApiClient()
    
    func registerUser<T:Codable>(email:String, password:String, firstName:String, lastName:String, birthday:String, gender:String, completion:@escaping (T?, Error?) -> ())
    {
        guard let url = NSURL.init(string: "\(baseUrl)/register.php") else { return }
        let params = "email=\(email)&password=\(password)&firstName=\(firstName)&lastName=\(lastName)&birthday=\(birthday)&gender=\(gender)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            if let data = data {
                if let decodeResponse = try? JSONDecoder().decode(T.self, from: data) {
                    completion(decodeResponse, nil)
                }
                return
            }
        }.resume()
    }
    
    func loginUser<T:Codable>(email:String, password:String, completion:@escaping (T?, Error?) -> ()) {
           guard let url = NSURL.init(string: "\(baseUrl)/login.php") else { return }
           let params = "email=\(email)&password=\(password)"
           
           var request = URLRequest(url: url as URL)
           request.httpMethod = "POST"
           let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
           request.httpBody = param!.data(using: .utf8)
           
           URLSession.shared.dataTask(with: request) { (data, response, error) in
               
               if error != nil {
                   completion(nil, error)
                   return
               }
               if let data = data {
                   if let decodeResponse = try? JSONDecoder().decode(T.self, from: data) {
                       completion(decodeResponse, nil)
                   }
                   return
               }
           }.resume()
       }
    
    
    
    func uploadImage<T:Codable>(id:String, type:String, image:UIImage, fileName:String, completion:@escaping(T?, Error?) -> Void) {
        guard let url = NSURL.init(string: "\(baseUrl)/uploadImage.php") else { return }
        let params = ["id":id,"type":type]
        let boundary = "Boundary-\(NSUUID().uuidString)"
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = image.jpegData(compressionQuality: 0.5)
        request.httpBody = Helper.body(with: params, filename:"\(fileName).jpg" , filePathKey: "file", imageDataKey: imageData!, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
                let decodeResponse = try JSONDecoder().decode(T.self, from: data!)
                    completion(decodeResponse, nil)
             
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func updateBio<T:Codable>(id:String, bio:String, completion:@escaping (T?, Error?) -> Void) {
        guard let url = NSURL.init(string: "\(baseUrl)/updateBio.php") else { return }
        let params = "id=\(id)&bio=\(bio)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion(nil, error)
                return
            }
            if let data = data {
                if let decodeResponse = try? JSONDecoder().decode(T.self, from: data) {
                    completion(decodeResponse, nil)
                }
                return
            }
        }.resume()
    }
}
