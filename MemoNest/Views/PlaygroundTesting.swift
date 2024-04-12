//
//  PlaygroundTesting.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/11/24.
//

import SwiftUI


struct PlaygroundView: View {
    @State private var expanded: Bool = false

    var body: some View {
        List {
            Section(header: HeaderView(expanded: $expanded)) {
                if expanded {
                    CircleView()
                }
            }
        }
    }
}

struct HeaderView: View {
    @Binding var expanded: Bool

    var body: some View {
        Text("Header")
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
                }
            }
    }
}

struct CircleView: View {
    // Your PlaybackView code here
    var body: some View {
        Circle()
    }
}

#Preview {
    PlaygroundView()
}
