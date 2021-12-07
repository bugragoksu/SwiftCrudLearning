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
    func fetchGists(completion : @escaping (Result<Any,Error>)->Void){
       componentURL.path = "/gists"
       
       guard let validURL = componentURL.url else {
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
               let json = try JSONSerialization.jsonObject(with: validData, options: [])
               completion(.success(json))
           }catch let serializationError{
               completion(.failure(serializationError))
           }
           
       }.resume()
       
   }
    
}
