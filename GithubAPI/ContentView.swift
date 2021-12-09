//
//  ContentView.swift
//  GithubAPI
//
//  Created by USER on 7.12.2021.
//

import SwiftUI

struct ContentView: View {
    @State private var starGistText = "Star"
    @State private var staredGist = false
    var body: some View {
        VStack {
            Button("Get Gists"){
                
                DataService.shared.fetchGists { result in
                    switch result{
                    case.success(let gists):
                        for gist in gists{
                            print("\(gist)\n")
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            Button("Post Gist"){
                DataService.shared.createNewGist(gist: Gist(id: nil, isPublic: true, description: "Hello world", files: ["test_file.txt":File(content: "Hello World")])) { result in
                    switch result{
                    case .failure(let error):
                        print(error)
                    case .success(let json):
                        print(json)
                    }
                }
            }
            
            Button(starGistText){
                self.staredGist = !staredGist
                starGistText = staredGist ? "Unstar" : "Star"
                DataService.shared.starUnStarGist(id: "b60886baae3a799d803c7ef52cc753d0", star: staredGist) { result in
                    print(result)
                }
                
            }
                
           
            
            
        }
        .padding()
            .buttonStyle(.bordered)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
