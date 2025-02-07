//
//  BookMarksView.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//
// Экран для отображения сохраненных постов

import SwiftUI

struct BookMarksView: View {
    
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(BookMarksViewModel.self) var bookMarks
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView() {
                if let bookMarks = bookMarks.bookmarks {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach((bookMarks.items ?? []), id: \.added_date) { item in
                            if let post = item.post {
                                NewsItemView(news: .constant(nil), item: post)
                            }
                        }
                        
                        Capsule()
                            .opacity(0)
                            .onAppear {
                                Task { await self.bookMarks.getBookmarks(offset: bookMarks.items?.count ?? 0) }
                            }
                    }
                }
                
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: scenePhase) { _, newValue in
            guard newValue == .active else { return }
            Task { await bookMarks.getBookmarks(offset: 0) }
        }
        .onChange(of: bookMarks.session.currentSession?.accessToken.value) { oldValue, newValue in
            Task {
                if bookMarks.bookmarks == nil { await bookMarks.getBookmarks(offset: 0) }
            }
        }
    }
}

#Preview {
    BookMarksView()
}
