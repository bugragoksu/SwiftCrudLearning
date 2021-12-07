//
//  ContentView.swift
//  GithubAPI
//
//  Created by USER on 7.12.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Button("Hello"){
            DataService.shared.fetchGists { result in
                switch result{
                case.success(let json):
                    print(json)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
