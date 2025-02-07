//
//  Profile.swift
//  VK Client
//
//  Created by Виталий Мишин on 24.01.2025.
//
// Модель данных профиля

import Foundation

struct Profile: Codable {
    let id : Int?
    let sex : Int?
    let screenName : String?
    let photo50 : String?
    let photo100 : String?
    let photoBase : String?
    let onlineInfo : OnlineInfo?
    let online : Int?
    let deactivated : String?
    let firstName : String?
    let lastName : String?
    let canAccessClosed : Bool?
    let isClosed : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case sex = "sex"
        case screenName = "screen_name"
        case photo50 = "photo_50"
        case photo100 = "photo_100"
        case photoBase = "photo_base"
        case onlineInfo = "online_info"
        case online = "online"
        case deactivated = "deactivated"
        case firstName = "first_name"
        case lastName = "last_name"
        case canAccessClosed = "can_access_closed"
        case isClosed = "is_closed"
    }
}

struct OnlineInfo : Codable {
    let visible : Bool?
    let isOnline : Bool?
    let isMobile : Bool?
    
    enum CodingKeys: String, CodingKey {
        
        case visible = "visible"
        case isOnline = "is_online"
        case isMobile = "is_mobile"
    }
}
