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
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    func test_fetchFunction() async {
        ///error:'async' call in a function that does not support concurrency
        ///Call can throw, but it is not marked with 'try' and the error is not handled
        ///書き方わからず、本当は1〜5まで自動的に値を入れてそれを

        let numbers = 1...5
//        var qiita:Qiita = Qiita(dataArray: [], responseLinks: [])
        numbers.forEach{ number in
            Task{
                let qiitaresult = try await mock.fetch(1, number)
                //                    print("array:\(qiita.dataArray)")
//                qiita = qiitaresult
                XCTAssertEqual(qiitaresult.dataArray.count, number)
            }
            }
            
//        Task{
//            var array = try await mock.fetch(1)
//            XCTAssertEqual(array.count, 1)
//        }
        
    }
    class ModelMock: ModelProtocol {
        
        
        func fetch (_ pageNo:Int,_ perPageNo:Int)async throws ->Qiita{
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
