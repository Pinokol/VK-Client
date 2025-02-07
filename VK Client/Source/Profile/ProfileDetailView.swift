//
//  ProfileDetailView.swift
//  VK Client
//
//  Created by Виталий Мишин on 01.02.2025.
//

import Observation
import SwiftUI

struct ProfileDetailView: View {
    
    @Environment(SessionViewModel.self) var session
    
    @State var detail: ProfileDetailViewModel = .init()
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.postBackground
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                header
                Color.primaryText
                    .frame(height: 1)
                    .padding(.bottom, 16)
                primaryInfo
                    .padding(.horizontal, 20)
            }
            
        }
        .onAppear {
            guard let token = session.currentSession?.accessToken.value else { return }
            Task {
                await detail.fetchInfo(with: token)
            }
        }
    }
    
    var header: some View {
        ZStack(alignment: .leading) {
            
            if let profileInfo = detail.profileInfo {
                
                Color.secondaryText
                    .opacity(0.25)
                    .frame(height: 48)
                let headerString: String = {
                    var result = ""
                    
                    if let first_name = profileInfo.first_name {
                        result += first_name
                    }
                    
                    if let last_name = profileInfo.last_name {
                        
                        result += " \(last_name)"
                    }
                    
                    
                    if let maiden_name = profileInfo.maiden_name {
                        
                        result += " (\(maiden_name))"
                    }
                    
                    return result
                }()
                
                Text(headerString)
                    .font(.inter(weight: .bold, size: 24))
                    .foregroundStyle(Color.primaryText)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    var primaryInfo: some View {
        ZStack() {
            if let profileInfo = detail.profileInfo {
                VStack(alignment: .leading, spacing: 10) {
                    
                    detailRow(image: "at", label: profileInfo.screen_name ?? "")
                    
                    detailRow(image: "gift", label: profileInfo.bdate ?? "")
                    detailRow(image: "house", label: profileInfo.city?.title ?? "")
                    detailRow(image: "heart", label: detail.describeRelation(value: profileInfo.relation, with: profileInfo.sex))
                }
                
            }
        }
    }
    
    func detailRow(image: String, label: String) -> some View {
        HStack() {
            Image(systemName: image)
                .foregroundStyle(Color.secondaryText)
            
            Text(label)
                .font(.inter(weight: .medium, size: 20))
                .foregroundStyle(Color.primaryText)
        }
    }
    
}

@Observable final class ProfileDetailViewModel {
    
    let api: API = .init()
    
    var profileInfo: ProfileDetailData?
    // Функция для получения подробной информации о пользователе
    func fetchInfo(with token: String) async {
        
        let payload: [String: Any] = [
            "access_token": token,
            "v": "5.245"
        ]
        
        let result = await api.request(.post, .accountGetProfileInfo, token: token, payload: payload, as: ProfileDetailResponse.self, .background, isDebug: false)
        
        await MainActor.run {
            self.profileInfo = result?.response
        }
        
    }
    // Функция для расшифровки отношений пользователя
    func describeRelation(value: Int?, with sex: ProfileSex?) -> String {
        
        switch sex {
        case .female:
            switch value {
            case 1: return "не замужем"
            case 2: return "есть друг"
            case 3: return "помолвлена"
            case 4: return "замужем"
            case 5: return "всё сложно"
            case 6: return "в активном поиске"
            case 7: return "влюблена"
            case 8: return "в гражданском браке"
            default: return "не указано"
            }
        case .male:
            switch value {
            case 1: return "не женат"
            case 2: return "есть подруга"
            case 3: return "помолвлен"
            case 4: return "женат"
            case 5: return "всё сложно"
            case 6: return "в активном поиске"
            case 7: return "влюблён"
            case 8: return "в гражданском браке"
            default: return "не указано"
            }
        default:
            switch value {
            case 1: return "не женат/не замужем"
            case 2: return "есть друг/есть подруга"
            case 3: return "помолвлен/помолвлена"
            case 4: return "женат/замужем"
            case 5: return "всё сложно"
            case 6: return "в активном поиске"
            case 7: return "влюблён/влюблена"
            case 8: return "в гражданском браке"
            default: return "не указано"
            }
        }
        
        
    }
    
}

#Preview {
    ProfileDetailView()
        .environment(SessionViewModel())
}


struct ProfileDetailResponse: Codable {
    let response: ProfileDetailData?
}

struct ProfileDetailData: Codable {
    let id: Int?
    let home_town: String?
    let status: String?
    let photo_200: String?
    let bdate: String?
    let first_name: String?
    let last_name: String?
    let maiden_name: String?
    let bdate_visibility: BDateVisibility?
    let city: ProfileCity?
    let phone: String?
    let relation: Int?
    let screen_name: String?
    let sex: ProfileSex?
    
}

enum BDateVisibility: Int, Codable {
    case hidden
    case visible
    case dayMonthOnly
}

enum ProfileSex: Int, Codable {
    case notDefined
    case female
    case male
}

struct ProfileCity: Codable {
    let id: Int?
    let title: String?
}

