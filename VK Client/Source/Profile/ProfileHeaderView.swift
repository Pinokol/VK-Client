//
//  ProfileHeaderView.swift
//  VK Client
//
//  Created by Виталий Мишин on 01.02.2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    
    @Environment(SessionViewModel.self) var session
    
    @State var showProfileDetail: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("ID: \(session.user?.id.value ?? 0)")
                .font(.inter(weight: .bold, size: 16))
                .foregroundStyle(Color.primaryText)
            HStack(alignment: .top, spacing: 0) {
                ZStack () {
                    Color.gray
                        .opacity(0.5)
                    if let url = session.user?.avatarURL {
                        AsyncImage(url: url, scale: 1.0) { image in
                            image
                                .resizable()
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image("ProfileIcon")
                    }
                    
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .padding(.trailing, 10)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(session.user?.firstName ?? "Ivan") \(session.user?.lastName ?? "Ivanov")")
                        .font(.inter(weight: .bold, size: 18))
                        .foregroundStyle(Color.primaryText)
                    Text("\(session.user?.email ?? "")")
                        .font(.inter(weight: .bold, size: 12))
                        .foregroundStyle(Color.secondaryText)
                    
                    Button(action: {
                        showProfileDetail.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image("Info")
                            Text("More details")
                                .foregroundStyle(Color.primaryText)
                                .font(.inter(weight: .bold, size: 14))
                        }
                    }
                }
                
                
                Spacer()
            }
            
        }
        .padding(.horizontal, 26)
        .popover(isPresented: $showProfileDetail) {
            ProfileDetailView()
                .presentationDetents([.height(200)])
        }
    }
    
}
