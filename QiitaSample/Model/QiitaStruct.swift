//
//  QiitaStruct.swift
//  QiitaSample
//
//  Created by 加藤研太郎 on 2023/02/17.
//

import Foundation
struct Qiita{
    var dataArray:[QiitaData]
    var responseLinks:[responseLink]
}
struct QiitaData: Decodable,Hashable,Equatable{
    let title:String
    let id :String
    let body:String
//    let coediting:Bool
    let url:String
    let createdAt:String
    let user:User
    let tags:[Tag]
    enum CodingKeys:String,CodingKey{
        case title
        case id
        case body
        case url
        case createdAt="created_at"
        case user
        case tags
    }
}

struct User:Decodable,Hashable,Equatable {
    let name:String
    let profileImage:String
    enum CodingKeys: String, CodingKey{
        case name
        case profileImage = "profile_image_url"
    }
}

struct Tag:Decodable,Hashable,Equatable {
    let name:String
    let versions:[String]
}
struct responseLink{
    let urlString:String
    let relation:String
}

