//
//  Playground.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 4/16/24.
//

import SwiftUI

struct Playground: View {
    @State var isGuestsExpanded: Bool = true
    var body: some View {
        List()  {
            ForEach( 0..<10 ) { num in
                DisclosureGroup {
                    VStack {
                        RoundedRectangle(cornerRadius: 25)
                            .frame(height: 200)
                        Text("more details on guest")
                    }
                } label: {
                    Text("Guest \(num)")
                }
            }
        }
    }
}


#Preview {
    Playground()
}
