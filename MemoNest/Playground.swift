//
//  Playground.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/16/24.
//

import SwiftUI
import UIKit

struct Playground: View {
    @State var isGuestsExpanded: Bool = true
    @State var value = 50.0
    var body: some View {
        VStack {
            Text("Philosophy Lecture #4")
//                .customFont(style: .title)
                .customFont(style: .title, fontWeight: .heavy)
//                .font(.custom("Poppins-Regular", size: 22))
            
            
            Slider(value: $value)
                .onAppear {
                    UISlider.appearance().thumbTintColor = .clear
                }
                .tint(Colors.icon)
                .padding()
        }
    }
}


#Preview {
    Playground()
}
