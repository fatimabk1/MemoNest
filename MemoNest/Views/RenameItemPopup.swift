//
//  RenameItemPopup.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI


// MARK: for renaming
struct RenameItemPopup: View {
    let action: (String) -> Void
    @State private var name = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader{ geo in
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                VStack {
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.white)
                        .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.3)
                        .overlay {
                            VStack {
                                Text("Rename")
                                    .padding()
                                    .font(.headline)
                                TextField("Enter folder name", text: $name)
                                    .padding()
                                    .background(.blue.opacity(0.2))
                                Spacer()
                                HStack {
                                    Button(action: { dismiss() }, label: {
                                        Text("Cancel")
                                            .foregroundStyle(.red)
                                    })
                                    Spacer()
                                    Button(action: { action(name) }, label: {
                                        Text("Save")
                                    })
                                }
                                .padding()
                            }
                        }
                }
            }
        }
    }
}

#Preview{
    return RenameItemPopup(action: {_ in })
}
