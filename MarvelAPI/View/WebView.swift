//
//  WebView.swift
//  MarvelAPI
//
//  Created by Maxim Macari on 15/3/21.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        
        let view = WKWebView()
        view.load(URLRequest(url: url))
        
        return view
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}


