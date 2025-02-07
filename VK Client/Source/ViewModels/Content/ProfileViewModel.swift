//
//  ProfileViewModel.swift
//  VK Client
//
//  Created by Виталий Мишин on 05.02.2025.
//

import Observation
import SwiftUI
import VKID


@Observable final class ProfileViewModel {
    
    let session: SessionViewModel
    
    let api: API = .init()
    
    var friends: ProfilesData?
    var followers: ProfilesData?
    var photos: PhotosData?
    
    init(session: SessionViewModel) {
        self.session = session
    }
    
    //Функция для получения информации о друзьях
    func fetchFriends() async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        let payload: [String: Any] = [
            "access_token": token,
            "order": "random",
            "count": 2,
            "offset": 0,
            "fields": "photo_100",
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .friendsGet, token: token, payload: payload, as: FriendsResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            self.friends = result?.response
        }
    }
    //Функция для получения подписчиков пользователя
    func fetchFollowers() async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        let payload: [String: Any] = [
            "access_token": token,
            "count": 2,
            "offset": 0,
            "fields": "photo_100",
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .getFollowers, token: token, payload: payload, as: FriendsResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            self.followers = result?.response
        }
    }
    
    // Функция для получения фотографий пользователя
    func fetchPhotos() async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        let payload: [String: Any] = [
            "access_token": token,
            "owner_id": "\(session.user?.id.value ?? 0)",
            "count": 15,
            "offset": 0,
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .photosGetAll, token: token, payload: payload, as: PhotosResponse.self, .background, isDebug: true)
        
        await MainActor.run {
            self.photos = result?.response
        }
    }
     
}

struct FriendsResponse: Codable {
    let response: ProfilesData?
}

struct ProfilesData: Codable {
    let count: Int?
    let items: [Profile]?
}


struct PhotosResponse: Codable {
    let response: PhotosData?
}

struct PhotosData: Codable {
    let count: Int?
    let items: [Photo]?
}

