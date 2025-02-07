//
//  AppSettings.swift
//  VK Client
//
//  Created by Виталий Мишин on 11.01.2025.
//

import Foundation
import SwiftUI

class AppSettings {
    let adress: String = "https://api.vk.com/method/"
    let vcClientId: String = "52910680"
    let vcClientSecret: String = "2BeD8GZajYfYir4xmvJM"
}

extension Font {
    // Функция для получения шрифта
    static func inter(weight: Weight, size: CGFloat) -> Font {
        
        switch weight {
        case .black: return Font.custom("Inter-Black", size: size)
        case .heavy: return Font.custom("Inter-ExtraBold", size: size)
        case .bold:  return Font.custom("Inter-Bold", size: size)
        case .semibold: return Font.custom("Inter-SemiBold", size: size)
        case .medium: return Font.custom("Inter-Medium", size: size)
        case .regular: return Font.custom("Inter-Regular", size: size)
        case .light: return Font.custom("Inter-Light", size: size)
        case .ultraLight: return Font.custom("Inter-ExtraLight", size: size)
        case .thin: return Font.custom("Inter-Thin", size: size)
        default: return Font.custom("Inter-Regular", size: size)
        }
    }
    
}
