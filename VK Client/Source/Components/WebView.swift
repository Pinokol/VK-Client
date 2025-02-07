//
//  WebView.swift
//  VK Client
//
//  Created by Виталий Мишин on 31.01.2025.
//
// Обертка для WKWebView


import WebKit
import SwiftUI

struct WebView: UIViewRepresentable {
    
    @Binding var link: String?
    
    let api: API = .init()
    
    func makeUIView(context: Context) -> WKWebView {
        
        let preferences = WKPreferences()
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let view = WKWebView(frame: .zero, configuration: configuration)
        
        
        return view
    }
    
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let link = link, let url = URL(string: link) {
            uiView.load(URLRequest(url: url))
        }
    }
    
    
}
