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
    case invaildData
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
        case .invaildData:
            return "得られたdataが無効です"
        }
    }
}
final class ViewModel{
    @Published private (set) var stateOfViewModel:StateOfViewModel?
    private (set) var qiita = Qiita(dataArray: [], responseLinks: [])
//    @Published private (set) var qiita:Qiita
    private let model :Model
    init(model: Model) {
        self.model = model
    }
    func fetchQiita() async throws{
        stateOfViewModel = .loading
        do{
            let receivedQiita = try await model.fetch()
            qiita.dataArray.append(contentsOf:  receivedQiita.dataArray)
            qiita.responseLinks = receivedQiita.responseLinks
            stateOfViewModel = .loaded
        }catch{
            stateOfViewModel = .error(error.localizedDescription)
            throw error
        }
    }
    func pagination(row:Int) throws{
//        guard let qiita = qiita else{throw ViewModelError.failedUnwrap}
        let nextURLString = qiita.responseLinks.filter{$0.relation == "next"}[0].urlString
        if row == qiita.dataArray.count - 1, nextURLString.contains("https://qiita.com/api/v2/items?page="){
            model.updateURL(nextURLString)
            Task{
                try await self.fetchQiita()
            }
        }else{
            stateOfViewModel = .error(ViewModelError.invaildURL.localizedDescription)
            throw ViewModelError.invaildURL
        }
    }
    func returnImageFromURL(urlString:String) async throws->UIImage{
        guard let url = URL(string: urlString) else{throw ViewModelError.invaildURL }
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data) else{throw ViewModelError.failedGeneratingImage}
        return image
        ///error
        ///Synchronous URL loading of https://lh3.googleusercontent.com/a-/AOh14GiHDumucs3o6fmzfrEsScv2xRCHlOlUpn5zNq5u=s50 should not occur on this application's main thread as it may lead to UI unresponsiveness. Please switch to an asynchronous networking API such as URLSession.
    }
    
}
