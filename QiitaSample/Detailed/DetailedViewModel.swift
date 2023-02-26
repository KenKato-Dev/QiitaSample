//
//  DetailedViewModel.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import Foundation
import WebKit
final class DetailedViewModel{
    
    func loadWebView(_ urlString:String, webView:WKWebView) throws{
        guard let url = URL(string: urlString) else {throw DetailedViewError.invaildURL}
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
