//
//  DetailedViewController.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import UIKit
import Combine
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
    private var cancellable = Set<AnyCancellable>()
    private var indicatorBackView = UIView()
    private let activityIndicator = UIActivityIndicatorView()
    private let detailedViewModel = DetailedViewModel()
    var urlString:String = ""

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
extension DetailedViewController{
    func binding(){
        detailedViewModel.$stateOfViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stateOfDetailedViewModel in
                guard let stateOfDetailedViewModel = stateOfDetailedViewModel else{return}
                switch stateOfDetailedViewModel{
                case .loading:
                    self?.showIndicator()
                case .loaded:
                    self?.hideIndicator(true)
                case let .error(message):
                    self?.hideIndicator(true)
                    self?.showErrorMessageIfNeeded(message)
                }
            }.store(in: &cancellable)
    }
    private func showErrorMessageIfNeeded(_ message: String) {
        let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "閉じる", style: .default))
        present(alert, animated: true)
    }
    private func showIndicator() {
        indicatorBackView = UIView(frame: view.bounds)
        indicatorBackView.backgroundColor = .white
        indicatorBackView.alpha = 0.5
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        activityIndicator.color = .gray
        activityIndicator.center = view.center
        view.addSubview(indicatorBackView)
        indicatorBackView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    private func hideIndicator(_ isHidden: Bool) {
        activityIndicator.isHidden = isHidden
        indicatorBackView.isHidden = isHidden
    }
}
