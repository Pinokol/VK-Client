//
//  BookMarksViewModel.swift
//  VK Client
//
//  Created by Виталий Мишин on 15.01.2025.
//

import Observation
import SwiftUI
import VKID


@Observable final class BookMarksViewModel {
    
    let session: SessionViewModel
    
    let api: API = .init()
    
    var bookmarks: BookMarkData?
    
    init(session: SessionViewModel) {
        self.session = session
    }
    
    // Функция для получения сохранных постов
    func getBookmarks(offset: Int?) async {
        
        guard let token = session.currentSession?.accessToken.value else { return }
        
        var payload: [String: Any] = [
            "access_token": token,
            "extended": 1,
            "item_type": "post",
            "count": 25,
            "v": "5.245"
        ]
        
        if let offset { payload["offset"] = offset }
        
        let result = await api.request(.post, .faveGet, token: token, payload: payload, as: BookMarksGetResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            if self.bookmarks == nil {
                self.bookmarks = result?.response
            } else {
                self.bookmarks?.items?.append(contentsOf: result?.response?.items ?? [])
                self.bookmarks?.groups?.append(contentsOf: result?.response?.groups ?? [])
                self.bookmarks?.profiles?.append(contentsOf: result?.response?.profiles ?? [])
            }
            
        }
    }
    // Функция для сохранения поста
    func addToBookmarks(post id: Int, with ownerID: Int) async -> Bool {
        
        guard let token = session.currentSession?.accessToken.value else { return false }
        
        let payload: [String: Any] = [
            "access_token": token,
            "owner_id": ownerID,
            "id": id,
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .faveAddPost, token: token, payload: payload, as: BookMarkActionResponse.self, .background, isDebug: true)
        
        return result?.response ?? 0 > 0 ? true : false
    }
    // Функция для удаления поста
    func removeFromBookmarks(post id: Int, with ownerID: Int) async -> Bool {
        
        guard let token = session.currentSession?.accessToken.value else { return false }
        
        let payload: [String: Any] = [
            "access_token": token,
            "owner_id": ownerID,
            "id": id,
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .faveRemovePost, token: token, payload: payload, as: BookMarkActionResponse.self, .background, isDebug: true)
        
        return result?.response ?? 0 > 0 ? true : false
    }
    
}


struct BookMarkActionResponse: Codable {
    let response: Int?
}


struct BookMarksGetResponse: Codable {
    let response: BookMarkData?
}

struct BookMarkData: Codable {
    let count: Int?
    var items: [BookMarkItem]?
    var profiles: [Profile]?
    var groups: [VKGroup]?
    let reactionSets: [ReactionSet]?
}

struct BookMarkItem: Codable {
    
    let added_date: Int?
    let seen: Bool?
    let type: String?
    let post: NewsItem?
}
