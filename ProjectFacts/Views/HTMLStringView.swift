//
//  HTMLStringView.swift
//  ProjectFacts
//
//  Created by Andre Albach on 26.06.23.
//

import SwiftUI
import WebKit

/// A view which will be able to present an HTML string
struct HTMLStringView: NSViewRepresentable {
    
    typealias NSViewType = WKWebView
    
    /// The html content which should be shown
    let htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}
