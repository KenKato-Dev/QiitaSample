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
struct QiitaData: Decodable{
    let title:String
    let id :String
//    let coediting:Bool
    let url:String
    let createdAt:String
    let user:User
    let tags:[Tag]
    enum CodingKeys:String,CodingKey{
        case title = "title"
        case id = "id"
//        case coediting = "coediting"
        case url="url"
        case createdAt="created_at"
        case user = "user"
        case tags = "tags"
    }
}

struct User:Decodable {
    let name:String
    let profileImage:String
    enum CodingKeys: String, CodingKey{
        case name = "name"
        case profileImage = "profile_image_url"
    }
}

struct Tag:Decodable {
    let name:String
    let versions:[String]
}
enum Relation:String {
case next
case none
}
struct responseLink{
    let urlString:String
    let relation:String
}

