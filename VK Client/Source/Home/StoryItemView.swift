//
//  StoryItemView.swift
//  VK Client
//
//  Created by Виталий Мишин on 24.01.2025.
//

import SwiftUI

struct StoryItemView: View {
    
    @Binding var stories: StoriesData
    let item: StoryItem
    
    
    var body: some View {
        ZStack(){
            
            if let path = stories.groups?.first(where: {$0.id == -(item.stories?.first?.ownerId ?? 0)})?.photo100 {
                AsyncImage(url: URL(string: path)) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                
            } else if let path = stories.profiles?.first(where: {$0.id == (item.stories?.first?.ownerId ?? 0)})?.photo100 {
                AsyncImage(url: URL(string: path)) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                }
                
            } else {
                Circle()
                    .foregroundStyle(Color.secondaryText)
            }
            
            
            Circle()
                .strokeBorder(Color.primaryAccent, lineWidth: 1, antialiased: true)
            
        }
        .frame(width: 60, height: 60)
    }
}

