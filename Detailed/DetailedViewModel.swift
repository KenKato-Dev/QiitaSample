//
//  DetailedViewModel.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import Foundation
import WebKit
enum StateOfDetailedViewModel{
    case loading
    case loaded
    case error(String)
    
}
enum DetailedViewModelError:Error{
    case failedLoading
}
extension DetailedViewModelError:LocalizedError{
    var localizedDescription:String{
        switch self{
        case .failedLoading:
            return "URLの読み込みに失敗しました"
        }
    }
}
final class DetailedViewModel{
    @Published private (set) var stateOfViewModel : StateOfViewModel?
    
    func loadWebView(_ urlString:String, webView:WKWebView) throws{
        stateOfViewModel = .loading
        guard let url = URL(string: urlString) else {
            stateOfViewModel = .error(DetailedViewModelError.failedLoading.localizedDescription)
            throw DetailedViewModelError.failedLoading
        }
        let request = URLRequest(url: url)
        webView.load(request)
        stateOfViewModel = .loaded
    }
}
