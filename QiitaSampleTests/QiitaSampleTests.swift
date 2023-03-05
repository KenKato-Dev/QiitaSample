//
//  QiitaSampleTests.swift
//  QiitaSampleTests
//
//  Created by 加藤研太郎 on 2023/02/16.
//

import XCTest
@testable import QiitaSample

final class QiitaSampleTests: XCTestCase {
    private var mock = ModelMock()
    private let exp = XCTestExpectation(description: "test実行")

    func test_fetch機能() async {
        let numbers = 1...3
//        numbers.forEach{ number in
        let random = numbers.randomElement()!
                do{
                    let qiitaresult = try await mock.test_fetch動作(random, random)
                    XCTAssertEqual(qiitaresult.dataArray.count, random)
                    if random != 1{
                        XCTAssertEqual(qiitaresult.responseLinks.count, 4)
                    }else{
                        XCTAssertEqual(qiitaresult.responseLinks.count, 3)
                    }
                    print("取り出し成功")
                    self.exp.fulfill()
                }catch{
                    print(error.localizedDescription)
                    XCTAssertThrowsError(error)
                    self.exp.fulfill()
                }
//        }
        wait(for: [exp], timeout: 3.0)
    }
    class ModelMock {
        func test_fetch動作 (_ pageNo:Int,_ perPageNo:Int)async throws ->Qiita{
            var qiitaArray:[QiitaData] = []
            let qiitaAPI = "https://qiita.com/api/v2/items?page=\(pageNo)&per_page=\(perPageNo)"
            guard let apiURL = URL(string: qiitaAPI) else {
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
                print(ModelError.decodeError)
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
                //クロージャとしてStringからNSStringへ変換し、上記のFirstmatchで取り出したものの範囲にて処理を実行、今回は2要素分をそれぞれに実行
                let string:(Int)->String = { at in
                    NSString(string: link).substring(with: firstMatch.range(at: at))
                }
                let url = string(1)
                let rel = string(2)
                responseArray.append(responseLink(urlString: url, relation: rel))
            }
            print(responseArray)
            return Qiita(dataArray: qiitaArray, responseLinks: responseArray)
        }
    }
}
