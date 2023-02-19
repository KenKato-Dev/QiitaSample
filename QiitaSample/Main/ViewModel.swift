//
//  ViewModel.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/19.
//

import Foundation
enum StateOfViewModel{
    case loading
    case loaded
    case error(String)
    
}
enum ViewModelError:Error{
    case failedFetch
    case failedUnwrap
    case invaildNextURL
}
extension ViewModelError:LocalizedError{
    var localizedDescription:String{
        switch self{
        case .failedFetch:
            return "Fetch処理に失敗しました"
        case .failedUnwrap:
            return "アンラップに失敗しました"
        case .invaildNextURL:
            return "次ページのURLが無効です"
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
        do{
            stateOfViewModel = .loading
            let receivedQiita = try await model.fetch(1, 10)
            qiita?.dataArray.append(contentsOf: receivedQiita.dataArray)
            qiita?.responseLinks = receivedQiita.responseLinks
            stateOfViewModel = .loaded
        }catch{
            stateOfViewModel = .error(error.localizedDescription)
        }
    }
    func pagination()async throws{
        guard let qiita = qiita else{throw ViewModelError.failedUnwrap}
        let nextURLString = qiita.responseLinks.filter{$0.relation == "next"}[0].urlString
        if nextURLString.contains("https://qiita.com/api/v2/items?page="){
            model.updateURL(nextURLString)
        }else{
            throw ViewModelError.invaildNextURL
        }
    }
}
