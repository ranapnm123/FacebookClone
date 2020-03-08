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
            do {
            guard let data = data  else {
                completion(nil, error)
                return
                }
                 let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(decodeResponse, nil)
                
            } catch {
                    completion(nil, error)
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
                   } else {
                    completion(nil, error)
                }
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
        
        var imageData = Data()
        if image != UIImage(named: "HomeCover.jpg") && image != UIImage(named: "user.png") {
            imageData = image.jpegData(compressionQuality: 0.5)!
        }
        request.httpBody = Helper.body(with: params, filename:"\(fileName).jpg" , filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
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
    
    func updatePost<T:Codable>(userId:String, text:String, imageData:Data?, completion:@escaping(T?, Error?) -> Void) {
        guard let url = NSURL.init(string: "\(baseUrl)/uploadPost.php") else {
            return
        }
        let params = ["user_id":userId,"text":text]
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        
          let boundary = "Boundary-\(NSUUID().uuidString)"
                    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
          request.httpBody = Helper.body(with: params, filename:"\(NSUUID().uuidString).jpg" , filePathKey: "file", imageDataKey: imageData ?? nil , boundary: boundary) as Data

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
            guard let data = data  else {
                completion(nil, error)
                return
                }
                 let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(decodeResponse, nil)
                
            } catch {
                    completion(nil, error)
                }
        }.resume()
    }
    
    func updateUser<T:Codable>(id:String, email:String, password:String, isPass:String, fname:String, lName:String, birthday:String, gender:String, allowFriends:String, allowFollow:String, completion:@escaping (T?, Error?) -> Void) {
        guard let url = NSURL.init(string: "\(baseUrl)/updateUser.php") else { return }
               let params = "id=\(id)&email=\(email)&firstName=\(fname)&lastName=\(lName)&birthday=\(birthday)&gender=\(gender)&newPassword=\(isPass)&password=\(password)&allow_friends=\(allowFriends)&allow_follow=\(allowFollow)"
               
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
                       } else {
                        completion(nil, error)
                    }
                       return
                   }
               }.resume()
    }
    
    func getPosts<T:Codable>(id:String, offset:String, limit:String, completion:@escaping((T?, Error?) -> Void)) {
           guard let url = NSURL.init(string: "\(baseUrl)/selectposts.php") else { return }
           let params = "id=\(id)&offset=\(offset)&limit=\(limit)"
           
           var request = URLRequest(url: url as URL)
           request.httpMethod = "POST"
           let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
           request.httpBody = param!.data(using: .utf8)
           
           URLSession.shared.dataTask(with: request) { (data, response, error) in
              if error != nil {
                   completion(nil, error)
                   return
               }
               do {
               guard let data = data  else {
                   completion(nil, error)
                   return
                   }
                    let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                       completion(decodeResponse, nil)
                   
               } catch {
                       completion(nil, error)
                   }
           }.resume()
       }
    
    func likePost<T:Codable>(userId:String, postId:String, action:String, completion:@escaping((T?, Error?) -> Void)) {
              guard let url = NSURL.init(string: "\(baseUrl)/like.php") else { return }
              let params = "user_id=\(userId)&post_id=\(postId)&action=\(action)"
              
              var request = URLRequest(url: url as URL)
              request.httpMethod = "POST"
              let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
              request.httpBody = param!.data(using: .utf8)
              
              URLSession.shared.dataTask(with: request) { (data, response, error) in
                 if error != nil {
                      completion(nil, error)
                      return
                  }
                  do {
                  guard let data = data  else {
                      completion(nil, error)
                      return
                      }
                       let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                          completion(decodeResponse, nil)
                      
                  } catch {
                          completion(nil, error)
                      }
              }.resume()
          }
    
    func insertComment<T:Codable>(userId:String, postId:String, action:String, comment:String, completion:@escaping((T?, Error?) -> Void)) {
        guard let url = NSURL.init(string: "\(baseUrl)/comments.php") else { return }
        let params = "user_id=\(userId)&post_id=\(postId)&action=\(action)&comment=\(comment)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
           if error != nil {
                completion(nil, error)
                return
            }
            do {
            guard let data = data  else {
                completion(nil, error)
                return
                }
                 let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(decodeResponse, nil)
                
            } catch {
                    completion(nil, error)
                }
        }.resume()
    }
    
    func getPostComments<T:Codable>(postId:String, offset:String, limit:String, action:String, completion:@escaping((T?, Error?) -> Void)) {
           guard let url = NSURL.init(string: "\(baseUrl)/comments.php") else { return }
           let params = "post_id=\(postId)&action=\(action)&offset=\(offset)&limit=\(limit)"

           var request = URLRequest(url: url as URL)
           request.httpMethod = "POST"
           let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
           request.httpBody = param!.data(using: .utf8)
           
           URLSession.shared.dataTask(with: request) { (data, response, error) in
              if error != nil {
                   completion(nil, error)
                   return
               }
               do {
               guard let data = data  else {
                   completion(nil, error)
                   return
                   }
                    let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                       completion(decodeResponse, nil)
                   
               } catch {
                       completion(nil, error)
                   }
           }.resume()
       }
    
    func deleteComment<T:Codable>(commentId:String, action:String, completion:@escaping((T?, Error?) -> Void)) {
        guard let url = NSURL.init(string: "\(baseUrl)/comments.php") else { return }
        let params = "id=\(commentId)&action=\(action)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
           if error != nil {
                completion(nil, error)
                return
            }
            do {
            guard let data = data  else {
                completion(nil, error)
                return
                }
                 let decodeResponse = try JSONDecoder().decode(T.self, from: data)
                    completion(decodeResponse, nil)
                
            } catch {
                    completion(nil, error)
                }
        }.resume()
    }

    func deletePost<T:Codable>(postId:String, completion:@escaping((T?, Error?) -> Void)) {
        guard let url = URL.init(string: "\(baseUrl)/deletePost.php") else { return }
        let params = "id=\(postId)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(decodedResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func getFriends<T:Codable>(action: String, id:String, name:String, offset:String, limit:String, completion:@escaping((T?, Error?) -> Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else { return }
        let params = "action=\(action)&id=\(id)&name=\(name)&offset=\(offset)&limit=\(limit)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        let param = params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        request.httpBody = param!.data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
                guard let data = data else {
                    completion(nil, error)
                    return
                }
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(decodedResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func friendRequest<T:Codable>(action:String, userId:String, friendId:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else { return }
        let params = "action=\(action)&user_id=\(userId)&friend_id=\(friendId)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
            guard let data = data else {
                completion(nil, error)
                return
            }
            let jsonResponse = try JSONDecoder().decode(T.self, from: data)
            completion(jsonResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func getFriendRequests<T:Codable>(action:String, id:String, offset:String, limit:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else { return }
        let params = "action=\(action)&id=\(id)&offset=\(offset)&limit=\(limit)"
        
        var request = URLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            do {
            guard let data = data else {
                completion(nil, error)
                return
            }
            let jsonResponse = try JSONDecoder().decode(T.self, from: data)
            completion(jsonResponse, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func updateFollowUser<T:Codable>(action:String, userId: String, followUserId: String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else {
            return
        }
        let params = "action=\(action)&user_id=\(userId)&follow_id=\(followUserId)"
        
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completion(json, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
    
    func report<T:Codable>(postId:String, userId: String, reason: String, byUserId: String, completion:@escaping((T?, Error?)->Void)) {
           guard let url = URL.init(string: "\(baseUrl)/reports.php") else {
               return
           }
           let params = "post_id=\(postId)&user_id=\(userId)&reason=\(reason)&byUser_id=\(byUserId)"
           
           var request = URLRequest.init(url: url)
           request.httpMethod = "POST"
           request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
           
           URLSession.shared.dataTask(with: request) { (data, response, error) in
               if error != nil {
                   completion(nil, error)
               }
               
               do {
                   let json = try JSONDecoder().decode(T.self, from: data!)
                   completion(json, nil)
               } catch {
                   completion(nil, error)
               }
           }.resume()
           
       }
    
    func getRecommendedFriends<T:Codable>(action:String, userId: String, offset:String, limit:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else {
            return
        }
        let params = "action=\(action)&id=\(userId)&offset=\(offset)&limit=\(limit)"

        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completion(json, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }

    func updateNotification<T:Codable>(action:String,byUserId:String, userId: String, type:String, completion:@escaping((T?, Error?)->Void)) {
          guard let url = URL.init(string: "\(baseUrl)/notifications.php") else {
              return
          }
          let params = "action=\(action)&byUser_id=\(byUserId)&user_id=\(userId)&type=\(type)"

          var request = URLRequest.init(url: url)
          request.httpMethod = "POST"
          request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
          
          URLSession.shared.dataTask(with: request) { (data, response, error) in
              if error != nil {
                  completion(nil, error)
              }
              
              do {
                  let json = try JSONDecoder().decode(T.self, from: data!)
                  completion(json, nil)
              } catch {
                  completion(nil, error)
              }
          }.resume()
          
      }
    
    func getNotification<T:Codable>(action:String,byUserId:String, userId: String, type:String, offset:String, limit:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/notifications.php") else {
            return
        }
        let params = "action=\(action)&byUser_id=\(byUserId)&user_id=\(userId)&type=\(type)&offset=\(offset)&limit=\(limit)"

        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completion(json, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
    
    func updateNotificationViewed<T:Codable>(action:String,byUserId:String, userId: String, viewed:String, notifId:String, type:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/notifications.php") else {
            return
        }
        let params = "action=\(action)&byUser_id=\(byUserId)&user_id=\(userId)&type=\(type)&viewed=\(viewed)&id=\(notifId)"

        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completion(json, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
    
    func getMyFriends<T:Codable>(action:String,userId:String, limit: String, offset:String, completion:@escaping((T?, Error?)->Void)) {
        guard let url = URL.init(string: "\(baseUrl)/friends.php") else {
            return
        }
        let params = "action=\(action)&id=\(userId)&limit=\(limit)&offset=\(offset)"

        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.httpBody = (params.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                completion(nil, error)
            }
            
            do {
                let json = try JSONDecoder().decode(T.self, from: data!)
                completion(json, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
        
    }
}
