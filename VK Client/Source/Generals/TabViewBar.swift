//
//  TabViewBar.swift
//  VK Client
//
//  Created by Виталий Мишин on 11.01.2025.
//

import SwiftUI

/// Панель для переключения tabView
struct TabViewBar: View {
    
    @Binding var selection: ScreenSelection
    
    var body: some View {
        
        HStack(spacing: 0) {
            ForEach(ScreenSelection.allCases, id: \.self) { item in
                ZStack() {
                    Color.primary
                        .colorInvert()
                    VStack(spacing: 4) {
                        switch item {
                        case .home:
                            Image("HomeIcon")
                                .renderingMode(.template)
                            Text("Home")
                        case .profile:
                            Image("ProfileIcon")
                                .renderingMode(.template)
                            Text("Profile")
                        case .bookMarks:
                            Image("SaveIcon")
                                .renderingMode(.template)
                            Text("Saved")
                        }
                    }
                    .foregroundStyle(item == selection ? Color.primaryAccent : Color.primary)
                }
                .onTapGesture {
                    withAnimation { selection = item }
                }
            }
        }
        .frame(height: 64, alignment: .bottom)
    }
}
