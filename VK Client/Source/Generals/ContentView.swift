//
//  ContentView.swift
//  VK Client
//
//  Created by Виталий Мишин on 10.01.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(SessionViewModel.self) var session
    
    var body: some View {
        RootView()
            .blur(radius: session.currentSession == nil ? 16 : 0)
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .active else { return }
                if session.currentSession == nil { session.makeAuthSheet() }
            }
        
    }
}

#Preview {
    ContentView()
        .environment(SessionViewModel())
}
