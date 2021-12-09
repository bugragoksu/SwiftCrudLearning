//
//  DataService.swift
//  GithubAPI
//
//  Created by USER on 7.12.2021.
//

import Foundation
import SwiftUI

class DataService{
    static let shared = DataService()
    fileprivate var componentURL : URLComponents
    private init(){
        componentURL = URLComponents()
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
    }
    func fetchGists(completion : @escaping (Result<[Gist],Error>)->Void){
        let getComponents = createURLComponents(path: "/gists")
       
       guard let validURL = getComponents.url else {
           print("URL Creation failed")
           return
       }
       
       URLSession.shared.dataTask(with: validURL) { data, response, error in
           if let httpResponse = response as? HTTPURLResponse{
               print("API STATUS : \(httpResponse.statusCode)")
           }
           guard let validData = data, error == nil else {
               completion(.failure(error!))
               return
           }
           
           do {
               let gists = try JSONDecoder().decode([Gist].self, from: validData)
               completion(.success(gists))
           }catch let serializationError{
               completion(.failure(serializationError))
           }
           
       }.resume()
       
   }
    
    func createNewGist(gist : Gist, completion: @escaping (Result<Any,Error>)->Void){
        let postRequest = createRequest(url: "/gists", data: gist, method: "POST")
     
        URLSession.shared.dataTask(with: postRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse{
                print("Status code : \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else{
                completion(.failure(error!))
                return
            }
            do{
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            }catch let serializationError{
                completion(.failure(serializationError))
            }
            
        }.resume()
    }
    
    func createRequest(url : String,data : Gist?, method: String)->URLRequest{
        
        let postComponents = createURLComponents(path: url)
    
        let authString = "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"
        var authStringBase64 = ""
        
        if let authData = authString.data(using: .utf8){
            authStringBase64 = authData.base64EncodedString()
        }
        var request = URLRequest(url: postComponents.url!)
        request.httpMethod = method
        if data != nil {
            do{
                let body = try JSONEncoder().encode(data)
                request.httpBody = body
                
            }catch{
                print("Gist encoding failed...")
            }
        }
        request.setValue("Basic \(authStringBase64)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func starUnStarGist(id :String, star : Bool, completion : @escaping (Bool) -> Void){
        
        var starRequest = createRequest(url: "/gists/\(id)/star", data: nil, method: star ? "PUT" : "DELETE")
        starRequest.setValue("0", forHTTPHeaderField: "Content-Length")
       
        URLSession.shared.dataTask(with: starRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 204 {
                    completion(true)
                }else{
                    print("Error : \(String(describing: error?.localizedDescription))")
                    completion(false)
                }
            }
//
        }.resume()
    }
    
    private func createURLComponents(path: String)->URLComponents{
        componentURL.path = path
        return componentURL
    }
    
}
