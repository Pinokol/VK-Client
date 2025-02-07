//
//  ProfilesWidget.swift
//  VK Client
//
//  Created by Виталий Мишин on 05.02.2025.
//

import SwiftUI

struct ProfilesWidget: View {
    
    @Binding var data: ProfilesData?
    
    let label: LocalizedStringKey
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(String(data?.count ?? 0))
                    .font(.inter(weight: .semibold, size: 12))
                    .foregroundStyle(Color.primaryText)
                Text(label)
                    .font(.inter(weight: .regular, size: 12))
                    .foregroundStyle(Color.secondaryText)
            }
            Spacer()
            
            if let items = data?.items {
                ForEach(items, id: \.id) { item in
                    if let photo100 = item.photo100 {
                        AsyncImage(url: URL(string: photo100)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 24, height: 24)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.postBackground, lineWidth: 2, antialiased: true)
                        }
                        .padding(.horizontal, -2)
                        .zIndex(item.id == items.first?.id ? 1 : 0 )
                    }
                }
            }
        }
    }
}
