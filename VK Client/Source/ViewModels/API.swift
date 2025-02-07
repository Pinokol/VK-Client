//
//  API.swift
//  VK Client
//
//  Created by Виталий Мишин on 18.01.2025.
//

import Foundation

class API {
    // Функция дженерик для декодирования данных
    func decode<T: Decodable>(_ data: Data, as type: T.Type, qos: DispatchQoS.QoSClass = .background) async -> T? {
        
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: qos).async {
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                do {
                    let result = try decoder.decode(T.self, from: data)
                    continuation.resume(with: .success(result))
                } catch {
                    
#if DEBUG
                    print("Error decoding: \(error)")
#endif
                    
                    continuation.resume(with: .success(nil))
                }
            }
        }
        
    }
    // Функция дженерик для кодирования данных
    func encode<E: Encodable>(_ value: E, qos: DispatchQoS.QoSClass = .background) async -> Data? {
        
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: qos).async {
                
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                
                do {
                    let result = try encoder.encode(value.self)
                    continuation.resume(with: .success(result))
                } catch {
#if DEBUG
                    print("Error encoding: \(error)")
#endif
                    continuation.resume(with: .success(nil))
                }
            }
        }
    }
    // Функция для создания запросов
    func makeRequest(_ method: APIMethod, _ point: APIPoint, token: String, payload: [String: Any]) async -> URLRequest? {
        
        var components = URLComponents()
        components.queryItems = []
        
        for key in payload.keys {
            if let value = payload[key] {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems?.append(queryItem)
            }
        }
        
        let urlString = AppSettings().adress + point.rawValue + (components.string ?? "")
        
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        //request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-encoded", forHTTPHeaderField: "Content-Type")
        return request
    }
    // Функция дженерик для исполнения сетевых запросов
    func request<T: Decodable>(_ method: APIMethod, _ point: APIPoint, token: String, payload: [String: Any], as type: T.Type, _ qos: DispatchQoS.QoSClass = .background, isDebug: Bool = false) async -> T? {
        
        guard let request = await makeRequest(method, point, token: token, payload: payload) else { return nil }
        
        if isDebug {
            print("\(method.rawValue): \(String(describing: request.url))")
            if let fields = request.allHTTPHeaderFields { print("Headers: \(fields)") }
        }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let response = response as? HTTPURLResponse else { return nil }
            let statusCode = response.statusCode
            
            if isDebug {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response: \(jsonString.replacingOccurrences(of: "},{", with: "},\n{"))")
                }
            }
            
            if statusCode >= 200 && statusCode < 300 {
                let result = await decode(data, as: T.self)
                return result
            } else {
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    // Список запросов к серверу
    enum APIPoint: String {
        case storiesGet = "stories.get"
        case newsFeedGet = "newsfeed.get"
        case accountGetProfileInfo = "account.getProfileInfo"
        case usersGet = "users.get"
        case faveGet = "fave.get"
        case faveAddPost = "fave.addPost"
        case faveRemovePost = "fave.removePost"
        case friendsGet = "friends.get"
        case getFollowers = "users.getFollowers"
        case photosGetAll = "photos.getAll"
    }
    
    enum APIMethod: String {
        case get = "GET"
        case post = "POST"
    }
}
