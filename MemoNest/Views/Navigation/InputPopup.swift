//
//  InputPopup.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI


// MARK: for renaming
struct InputPopup: View {
    @State private var input: String
    let popup: PopupInput
    let action: (String?) -> Void
//    @Environment(\.dismiss) var dismiss

    init(popup: PopupInput, action: @escaping (String?) -> Void) {
        self._input = State(initialValue: popup.placeholder)
        self.popup = popup
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.3)
                .ignoresSafeArea()
            ZStack {
                Color("PopupBackground")
                VStack {
                    Text(popup.popupTitle)
                        .padding()
                        .font(.headline)
                    TextField(popup.prompt, text: $input)
                        .padding(.horizontal)
                    Divider()
                        .padding(.horizontal)
                    HStack {
                        Button {
                            action(nil)
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(.red)
                        }
                        Spacer()
                        Button {
                            action(input)
                        } label: {
                            Text("Save")
                        }
                    }
                    .padding()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview{
    let popup = PopupInput(popupTitle: "Rename", prompt: "Enter new folder name", placeholder: "")
    return InputPopup(popup: popup, action: {_ in })
}
