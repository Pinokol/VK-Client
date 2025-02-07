//
//  SessionViewModel.swift
//  VK Client
//
//  Created by Виталий Мишин on 11.01.2025.
//

import Combine
import Observation
import UIKit
import VKID

@Observable final class SessionViewModel {
    
    
    var currentSession: UserSession?
    var user: User?
    
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []
    
    let vkID: VKID
    let settings = AppSettings()
    let updateTimer = Timer.publish(every: 3540, on: .main, in: .common).autoconnect()
    
    init() {
        
        do {
            
            let config = Configuration(
                appCredentials: AppCredentials(clientId: settings.vcClientId, clientSecret: settings.vcClientSecret),
                loggingEnabled: true // Включите логи для отладки.
            )
            
            let vkid = try VKID(config: config)
            
            self.vkID = vkid
            
            self.currentSession = self.vkID.currentAuthorizedSession
            
            self.currentSession?.fetchUser(completion: { result  in
                do {
                    let user = try result.get()
                    self.user = user
                } catch {
                    print("Failed to fetch user info")
                }
            })
        } catch {
            fatalError(error.localizedDescription)
        }
        
        updateTimer
            .sink { _ in
                self.refreshSession()
            }
            .store(in: &cancellables)
    }
    
    // Функция для вызова страницы авторизации
    func makeAuthSheet() {
        
        let config = AuthConfiguration(flow: .publicClientFlow(),
                                       scope: Scope(["vkid.personal_info",
                                                     "email",
                                                     "phone",
                                                     "friends",
                                                     "wall",
                                                     "groups",
                                                     "stories",
                                                     "photos",
                                                     "video",
                                                     "status",
                                                     "notifications"]), forceWebViewFlow: true)
        
        let oneTapSheet = OneTapBottomSheet(
            serviceName: "VK client",
            targetActionText: .signIn,
            oneTapButton: .init(height: .medium(.h44),cornerRadius: 8),
            authConfiguration: config,
            theme: .matchingColorScheme(.system),
            autoDismissOnSuccess: true
        ) { authResult in
            // Обработка результата авторизации.
            do {
                let session = try authResult.get()
                print("Auth succeeded with token: \(session.accessToken)")
                self.currentSession = session
                
                self.currentSession?.fetchUser(completion: { result  in
                    do {
                        let user = try result.get()
                        self.user = user
                    } catch {
                        print("Failed to fetch user info")
                    }
                })
                
            } catch AuthError.cancelled {
                print("Auth cancelled by user")
            } catch {
                print("Auth failed with error: \(error)")
            }
        }
        
        let sheetViewController = vkID.ui(for: oneTapSheet).uiViewController()
        
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        
        guard let controller = keyWindow?.rootViewController else { return }
        
        controller.present(sheetViewController, animated: true)
    }
   // Функция для обновления сессии пользователя
    func refreshSession() {
        
        vkID.currentAuthorizedSession?.getFreshAccessToken(forceRefresh: true) { result in

        }
    }
}
