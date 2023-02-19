//
//  Model.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/15.
//

import Foundation

enum ModelError:Error{
    case invalidURL
    case responseError
    case decodeError
}
extension ModelError:LocalizedError{
    var errorDescription:String?{ //注意）この変数名にしなければ動かず
        switch self{
        case.invalidURL:return "URLが正しくないです"
        case .responseError:return "responseの取得に失敗しました"
        case.decodeError:return "デコードに失敗しました"
        }
    }
}
protocol ModelProtocol {
    func fetch (_ pageNo:Int,_ perPageNo:Int)async throws ->Qiita
}
final class Model:ModelProtocol{
    private var urlString:String = "https://qiita.com/api/v2/items?page=1&per_page=10"
    
    func fetch (_ pageNo:Int,_ perPageNo:Int)async throws ->Qiita{
        var qiitaArray:[QiitaData] = []
        guard let apiURL = URL(string: urlString) else {
            throw ModelError.invalidURL
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        if (response as? HTTPURLResponse)?.statusCode != 200{
            throw ModelError.responseError
        }
        let decoder = JSONDecoder()
        do{
            qiitaArray = try decoder.decode([QiitaData].self, from: data)
        }catch{
            throw ModelError.decodeError
        }
        //HttpHeaderからLinkField1を取り出し、,で分断
        let linkField = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Link")
        let linkArray = linkField!.components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespaces)}
        //正規表現でマッチできるかをみる
        var responseArray:[responseLink]=[]
        try linkArray.forEach{ link in
             let negex = try NSRegularExpression(pattern: "<(.*)>; rel=\"(.*)\"")
            let match =  negex.matches(in: link, range: NSRange(location: .zero, length: link.count))
            //Matchした要素をfirstとしてurlとrelの2つ分取れているかguard letで取り出し
            guard let firstMatch = match.first, firstMatch.numberOfRanges>=2 else{return}
            //クロージャとしてStringからNSStringへ変換し、上記のFirstmatchで取り出したものの範囲にて処理を実行、今回は2要素分をそれぞれに実行？
            let string:(Int)->String = { at in
                NSString(string: link).substring(with: firstMatch.range(at: at))
            }
            let url = string(1)
            let rel = string(2)
            responseArray.append(responseLink(urlString: url, relation: rel))
        }
//        print(responseArray)
        return Qiita(dataArray: qiitaArray, responseLinks: responseArray)
    }
    
    func updateURL(_ nextURLstring:String){
        self.urlString = nextURLstring
    }
}
