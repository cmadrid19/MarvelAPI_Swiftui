//
//  Home.swift
//  MarvelAPI
//
//  Created by Maxim Macari on 15/3/21.
//

import SwiftUI

struct Home: View {
    
    @StateObject var homeData = HomeViewModel()
    
    var body: some View {
        TabView{
            
            CharactersView()
                .tabItem {
                    Image(systemName: "person.3.fill")
                    Text("Characters")
                }
            //setting eenvironment object, so it has access from its parent
                .environmentObject(homeData)
                
            
            ComicsView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("Comics")
                }
                .environmentObject(homeData)
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
