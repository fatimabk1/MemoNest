//
//  RenameItemPopup.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI


// MARK: for renaming
struct RenameItemPopup: View {
    @State private var name: String
    let dismiss: () -> Void
    let action: (String) -> Void
    
    init(name: String, dismiss: @escaping () -> Void, action: @escaping (String) -> Void) {
        self._name = State(initialValue: name)
        self.dismiss = dismiss
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.3)
                .ignoresSafeArea()
            ZStack {
                Color.white
                VStack {
                    Text("Rename")
                        .padding()
                        .font(.headline)
                    TextField("Enter folder name", text: $name)
                        .padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                    HStack {
                        Button(action: { dismiss() }, label: {
                            Text("Cancel")
                                .foregroundStyle(.red)
                        })
                        Spacer()
                        Button {
                            action(name)
                            dismiss()
                        } label: {
                            Text("Save")
                        }
                    }
                    .padding()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray)
                    .foregroundStyle(.white)
            )
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview{
    return RenameItemPopup(name: "New Folder", dismiss: {}, action: {_ in })
}
