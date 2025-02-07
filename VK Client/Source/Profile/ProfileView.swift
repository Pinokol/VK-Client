//
//  ProfileView.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//

import SwiftUI
import VKID

struct ProfileView: View {

    @Environment(\.scenePhase) var scenePhase
    
    @Environment(ProfileViewModel.self) var profile
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 20) {
                
                ProfileHeaderView()
                
                ZStack() {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.postBackground)
                    HStack(spacing: 8) {
                        
                        ProfilesWidget(data: .constant(profile.friends), label: "friends")
                       
                        Color.primaryText
                            .frame(width: 0.5)
                            
                        ProfilesWidget(data: .constant(profile.followers), label: "followers")
                    }
                    .padding(8)
                }
                .padding(.horizontal, 20)
                
                if let photos = profile.photos {
                    
                    let gridSize: CGFloat = ((UIScreen.screenW - 16)/3) - 2
                    
                    LazyVGrid(columns: Array(repeating: .init(.fixed(gridSize), spacing: 2, alignment: .center), count: 3), spacing: 2) {
                        ForEach(photos.items ?? [], id: \.id) { photo in
                            if let link = photo.sizes?.last?.url {
                                AsyncImage(url: URL(string: link)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: gridSize, height: gridSize)
                                        .clipShape(.rect(cornerRadius: 2))
                                } placeholder: {
                                    ProgressView()
                                }
                                
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task {
                await profile.fetchFriends()
                await profile.fetchFollowers()
                await profile.fetchPhotos()
            }
        }
        .onChange(of: profile.session.currentSession?.accessToken.value) { _, _ in
            Task {
                if profile.friends == nil { await profile.fetchFriends() }
                if profile.followers == nil { await profile.fetchFollowers() }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(SessionViewModel())
    
}


