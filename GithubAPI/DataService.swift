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
        let postComponents = createURLComponents(path: "/gists")
        
        guard let composedURL = postComponents.url else {
            print("URL creation failed..")
            return
        }
        var postRequest = URLRequest(url: composedURL)
        
        
        let authString = "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"
        var authStringBase64 = ""
        
        if let authData = authString.data(using: .utf8){
            authStringBase64 = authData.base64EncodedString()
        }
        postRequest.setValue("Basic \(authStringBase64)", forHTTPHeaderField: "Authorization")
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        do{
            let gistData = try JSONEncoder().encode(gist)
            postRequest.httpBody = gistData
            postRequest.httpMethod = "POST"
        }catch{
            print("Gist encoding failed...")
        }
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
    
    
    private func createURLComponents(path: String)->URLComponents{
        componentURL.path = path
        return componentURL
    }
    
}
