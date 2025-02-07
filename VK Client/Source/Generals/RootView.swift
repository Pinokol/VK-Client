//
//  RootView.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//

import SwiftUI

struct RootView: View {
    @Environment(SessionViewModel.self) var session
    @State var selection: ScreenSelection = .home
    
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selection) {
                HomeView()
                    .tag(ScreenSelection.home)
                ProfileView()
                    .tag(ScreenSelection.profile)
                BookMarksView()
                    .tag(ScreenSelection.bookMarks)
            }
            .toolbar(.hidden, for: .tabBar)
            Color.primaryText
                .frame(height: 1)
                .opacity(0.25)
            TabViewBar(selection: $selection)
        }
    }
}



#Preview {
    RootView()
        .environment(SessionViewModel())
}
