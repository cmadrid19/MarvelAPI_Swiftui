//
//  ComicsView.swift
//  MarvelAPI
//
//  Created by Maxim Macari on 15/3/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ComicsView: View {
    
    @EnvironmentObject var homeData: HomeViewModel
    
    var body: some View {
        NavigationView{
            ScrollView(.vertical, showsIndicators: false, content: {

                if homeData.fetchedComics.isEmpty {
                    ProgressView()
                        .padding(.top, 30)
                }
                else {
                    //Displayinhg content
                    VStack(spacing: 15){
                        ForEach(homeData.fetchedComics){ comic in
                        
                            ComicRowView(comic: comic)
                        
                        }
                        
                        if homeData.offset == homeData.fetchedComics.count {
                            //showing progress and fetching new data
                            ProgressView()
                                .padding(.vertical)
                                .onAppear() {
                                    print("updating")
                                    homeData.fetchComics()
                                }
                        } else {
                            
                            //Infinit scroll
                            GeometryReader{ reader -> Color in
                                
                                let minY = reader.frame(in: .global).minY
                                
                                let height = UIScreen.main.bounds.height / 1.3
                                
                                // when it goes over the height triggering an update
                                
                                if !homeData.fetchedComics.isEmpty && minY < height {
                                    //setting offset to current fetched comics
                                    //current fetch offset + (20 of the current fetch)
                                    DispatchQueue.main.async {
                                        homeData.offset = homeData.fetchedComics.count
                                        print("homedata.offset: \(homeData.offset)")
                                    }
                                    
                                }
                                return Color.clear
                            }
                            .frame(width: 20, height: 20)
                        }
                       
                    }
                    .padding(.vertical)
                }
            })
            .navigationTitle("Maverl's comics")
        }
        //Loading
        .onAppear(){
            if homeData.fetchedComics.isEmpty{
                homeData.fetchComics()
            }
        }
    }
}

struct ComicsView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsView()
    }
}

struct ComicRowView: View {
    
    var comic: Comic
    
    var body: some View{
        HStack(alignment: .top, spacing: 15){
            
            WebImage(url: extractImage(data: comic.thumbnail))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8, content: {
                Text(comic.title)
                    .fontWeight(.bold)
                
                
                Text(comic.description ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                //Links
                HStack(spacing: 10){
                    ForEach(comic.urls, id: \.self){ data in
                        NavigationLink(
                            destination: WebView(url: extractURL(data: data))
                                .navigationTitle(extractURLType(data: data)),
                            label: {
                                Text("\(extractURLType(data: data))")
                            })
                    }
                }
            })
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
    
    private func extractImage(data: [String: String]) -> URL {
        
        let path = data["path"] ?? ""
        let ext = data["extension"] ?? ""
        
        return URL(string: "\(path).\(ext)")!
        
    }
    
    func extractURL(data: [String:String]) -> URL{
        let url = data["url"] ?? ""
        
        return URL(string: url)!
    }
    
    func extractURLType(data: [String:String]) -> String{
        let type = data["type"] ?? ""
        
        return type.capitalized
    }
    
    
}
