//
//  DetailedViewController.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import UIKit
import WebKit
enum DetailedViewError:Error{
    case invaildURL
}
extension DetailedViewError:LocalizedError{
    var localizedDescription:String{
        switch self{
        case .invaildURL:
            return "URLが無効です"

        }
    }
}
class DetailedViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    private let detailedViewModel = DetailedViewModel()
    var urlString:String = ""
    
//    override func loadView() {
//        super.loadView()
//        let webConfigration = WKWebViewConfiguration()
//        webView.uiDelegate = self
//        webView.navigationDelegate = self
//        self.view = webView
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
           try self.detailedViewModel.loadWebView(urlString, webView: self.webView)
        }catch{
            print(error.localizedDescription)
        }
        // Do any additional setup after loading the view.
    }
}
