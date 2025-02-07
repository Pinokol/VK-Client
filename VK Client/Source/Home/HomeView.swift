//
//  HomeView.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//

import AVKit
import Foundation
import SwiftUI
import WebKit

struct HomeView: View {
    @Environment(\.scenePhase) var scenePhase

    @Environment(HomeViewModel.self) var home
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd MMMM"
        return df
    }()
     
    var body: some View {
        VStack(spacing: 10) {
            ScrollView() {
                if let stories = home.stories {
                    ScrollView(.horizontal) {
                        HStack(alignment: .center, spacing: 12) {
                            ForEach(stories.items ?? []) { item in
                                StoryItemView(stories: .constant(stories), item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            
                HStack(spacing: 10) {
                    Color.secondaryText
                        .frame(height: 1)
                    
                    ZStack() {
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.secondaryText, lineWidth: 1, antialiased: true)
                        
                        Text(formatter.string(from: Date()))
                            .font(.inter(weight: .regular, size: 14))
                            .foregroundStyle(Color.secondaryText)
                    }
                    
                    .frame(width: 100, height: 24)
                    
                    Color.secondaryText
                        .frame(height: 1)
                }
                .padding(.horizontal, 16)
                
                if let news = home.newsFeed {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach((news.items ?? []).filter({$0.ownerID != nil}), id: \.internalID) { item in
                            NewsItemView(news: .constant(news), item: item)
                        }
                        
                        Capsule()
                            .opacity(0)
                            .onAppear {
                                Task() {
                                    await home.fetchNews(news.items?.count)
                                }
                            }
                    }
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task {
                await home.fetchStories()
                await home.fetchNews()
            }
        }
        .onChange(of: home.session.currentSession?.accessToken.value) { oldValue, newValue in
            Task {
                if home.stories == nil { await home.fetchStories() }
                if home.newsFeed == nil { await home.fetchNews() }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(HomeViewModel(session: SessionViewModel()))
}





