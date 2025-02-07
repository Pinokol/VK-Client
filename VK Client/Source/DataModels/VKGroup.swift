//
//  VKGroup.swift
//  VK Client
//
//  Created by Виталий Мишин on 24.01.2025.
//
// Модель данных сообщества вконтакте

import Foundation

struct VKGroup: Codable {
    let id : Int?
    let name : String?
    let screenName : String?
    let isClosed : Int?
    let type : String?
    let isAdmin : Int?
    let isMember : Int?
    let isAdvertiser : Int?
    let verified : Int?
    let photo50 : String?
    let photo100 : String?
    let photo200 : String?
    let photoBase : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case name = "name"
        case screenName = "screen_name"
        case isClosed = "is_closed"
        case type = "type"
        case isAdmin = "is_admin"
        case isMember = "is_member"
        case isAdvertiser = "is_advertiser"
        case verified = "verified"
        case photo50 = "photo_50"
        case photo100 = "photo_100"
        case photo200 = "photo_200"
        case photoBase = "photo_base"
    }
    
}
