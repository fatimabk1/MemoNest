//
//  CustomFontModifier.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/26/24.
//

import Foundation
import SwiftUI


struct CustomFontModifier: ViewModifier {
    let style: Font.TextStyle
    let fontWeight: Font.Weight
    
    func body(content: Content) -> some View {
        let uiFontStyle = mapFontTextStyle(style)
        let size = UIFont.preferredFont(forTextStyle: uiFontStyle).pointSize
        let fontName = "Poppins-\(mapFontWeight(fontWeight))"
        return content.font(.custom(fontName, size: size))
    }
    
    private func mapFontWeight(_ weight: Font.Weight) -> String {
        switch weight {
        case .ultraLight:
            return "UltraLight"
        case .thin:
            return "Thin"
        case .light:
            return "Light"
        case .regular:
            return "Regular"
        case .medium:
            return "Medium"
        case .semibold:
            return "SemiBold"
        case .bold:
            return "Bold"
        case .heavy:
            return "Heavy"
        case .black:
            return "Black"
        default:
            return "Regular"
        }
    }
    
    private func mapFontTextStyle(_ textStyle: Font.TextStyle) -> UIFont.TextStyle {
        switch textStyle {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        default:
            return .body
        }
    }
}

// TODO: customize font name,
extension View {
    func customFont(style: Font.TextStyle, fontWeight: Font.Weight = .regular) -> some View {
        self.modifier(CustomFontModifier(style: style, fontWeight: fontWeight))
    }
}
