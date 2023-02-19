//
//  ViewModel.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import Foundation
import UIKit

enum StateOfViewModel{
    case loading
    case loaded
    case error(String)
    
}
enum ViewModelError:Error{
    case failedFetch
    case failedUnwrap
    case invaildURL
    case failedGeneratingImage
}
extension ViewModelError:LocalizedError{
    var localizedDescription:String{
        switch self{
        case .failedFetch:
            return "Fetch処理に失敗しました"
        case .failedUnwrap:
            return "アンラップに失敗しました"
        case .invaildURL:
            return "URLが無効です"
        case .failedGeneratingImage:
            return "Imageの生成に失敗しました"
        }
    }
}
final class ViewModel{
    @Published private (set) var stateOfViewModel:StateOfViewModel?
    private (set) var qiita:Qiita?
    private let model :Model
    init(model: Model) {
        self.model = model
    }
    func fetchQiita() async throws{
        stateOfViewModel = .loading
        do{
            let receivedQiita = try await model.fetch()
            receivedQiita.dataArray.forEach{qiita?.dataArray.insert($0)}
            qiita?.responseLinks = receivedQiita.responseLinks
            stateOfViewModel = .loaded
        }catch{
            stateOfViewModel = .error(error.localizedDescription)
            throw error
        }
    }
    func pagination()async throws{
        guard let qiita = qiita else{throw ViewModelError.failedUnwrap}
        let nextURLString = qiita.responseLinks.filter{$0.relation == "next"}[0].urlString
        if nextURLString.contains("https://qiita.com/api/v2/items?page="){
            model.updateURL(nextURLString)
        }else{
            stateOfViewModel = .error(ViewModelError.invaildURL.localizedDescription)
            throw ViewModelError.invaildURL
        }
    }
    func returnImageFromURL(urlString:String) throws->UIImage{
        guard let url = URL(string: urlString) else{throw ViewModelError.invaildURL }
        do{
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else{throw ViewModelError.failedGeneratingImage}
            return image
        }catch{
            throw error
        }
    }
}
