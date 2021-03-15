//
//  HomeViewModel.swift
//  MarvelAPI
//
//  Created by Maxim Macari on 15/3/21.
//

import SwiftUI
import Combine
import CryptoKit

class HomeViewModel: ObservableObject {
    @Published var searchQuery = ""
    
    //used yo cancel the search publicher when ever we need
    var searchCancellable: AnyCancellable? = nil
    
    //fetch data
    @Published var fetchedCharacters: [Character]? = nil
    
    @Published var fetchedComics: [Comic] = [Comic]()
    
    @Published var offset: Int = 0
    
    //Combine
    init() {
        searchCancellable = $searchQuery
        //removing duplicates typings
            .removeDuplicates()
            //we dont need to fetch for every typing
            .debounce(for: 0.6, scheduler: RunLoop.main)
            .sink(receiveValue: { (str) in
                if str == "" {
                    //reset data
                    self.fetchedCharacters = nil
                }else{
//                    search data
                    self.searchCharacter()
                }
            })
    }
    
    func searchCharacter(){
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = generateHash(data: "\(timestamp)\(privateKey)\(publicKey)")
        let originalQuery = searchQuery.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://gateway.marvel.com:443/v1/public/characters?nameStartsWith=\(originalQuery)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        
        let session = URLSession(configuration: .default)
        
        guard let url = URL(string: urlString) else {
            print("invalid url")
            return
        }
        
        session.dataTask(with: URL(string: urlString)!) { (data, resp, error) in
            print("url: \(URL(string: urlString))")
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let APIData = data else {
                print("no data found")
                return
            }
            
            do {
                //decoding
                let characters = try JSONDecoder().decode(APIResult.self, from: APIData)
                
                DispatchQueue.main.async {
                    if self.fetchedCharacters == nil{
                        self.fetchedCharacters = characters.data.results
                        print(self.fetchedCharacters)
                    }
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
        .resume()
    }
    
//    to generate hash we are going to use cryptoKit
    func generateHash(data: String) -> String{
        let hash = Insecure.MD5.hash(data: data.data(using: .utf8) ?? Data())
        
        return hash.map {
            String(format: "%02hhx", $0)
        }
        .joined()
    }
    
    func fetchComics(){
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = generateHash(data: "\(timestamp)\(privateKey)\(publicKey)")
        
        let urlString = "https://gateway.marvel.com:443/v1/public/comics?limit=20offset=\(offset)&ts=\(timestamp)&apikey=\(publicKey)&hash=\(hash)"
        
        let session = URLSession(configuration: .default)
        
        guard let url = URL(string: urlString) else {
            print("invalid url")
            return
        }
        
        
        
        session.dataTask(with: URL(string: urlString)!) { (data, resp, error) in
            print("url: \(URL(string: urlString))")
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let APIData = data else {
                print("no data found")
                return
            }
            
            do {
                //decoding
                let comics = try JSONDecoder().decode(APIComicResult.self, from: APIData)
                
                DispatchQueue.main.async {
                    self.fetchedComics.append(contentsOf: comics.data.results)
                }
            }
            catch{
                print(error.localizedDescription)
            }
        }
        .resume()
    }
    
}


