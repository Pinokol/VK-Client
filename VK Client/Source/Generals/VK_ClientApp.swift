//
//  VK_ClientApp.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//
// Точка запуска приложения

import SwiftUI

@main
struct VK_ClientApp: App {
    
    @State var session: SessionViewModel
    @State var bookMarks: BookMarksViewModel
    @State var home: HomeViewModel
    @State var profile: ProfileViewModel
    
    init() {
        let session = SessionViewModel()
        let bookMarks = BookMarksViewModel(session: session)
        let home = HomeViewModel(session: session)
        let profile = ProfileViewModel(session: session)
        
        self._bookMarks = State(wrappedValue: bookMarks)
        self._home = State(wrappedValue: home)
        self._profile = State(wrappedValue: profile)
        self._session = State(wrappedValue: session)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(session)
                .environment(bookMarks)
                .environment(home)
                .environment(profile)
                .onOpenURL { url in
                    _ = session.vkID.open(url: url)
                }
        }
    }
}
