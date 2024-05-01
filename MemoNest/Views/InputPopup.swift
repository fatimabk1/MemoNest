//
//  InputPopup.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI


struct InputPopup: View {
    @State private var input: String
    let popup: PopupInput
    let action: (String?) -> Void

    init(popup: PopupInput, action: @escaping (String?) -> Void) {
        self._input = State(initialValue: popup.placeholder)
        self.popup = popup
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.blueVeryDark
                .opacity(0.7)
                .ignoresSafeArea()
            ZStack {
                Colors.background
                VStack {
                    Text(popup.popupTitle)
                        .padding()
                        .memoNestFont(style: .headline)
                        .foregroundStyle(Colors.mainText)
                    TextField("", text: $input, prompt: Text(popup.prompt).foregroundStyle(Colors.blueDark))
                        .memoNestFont(style: .body)
                        .padding(.horizontal)
                        .foregroundStyle(Colors.blueLight)
                    Divider()
                        .padding(.horizontal)
                        .foregroundStyle(Colors.blueMedium)
                    HStack {
                        Button {
                            action(nil)
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(Colors.icon)
                                .memoNestFont(style: .body)
                        }
                        Spacer()
                        Button {
                            action(input)
                        } label: {
                            Text("Save")
                            .foregroundStyle(Colors.blueLight)
                            .memoNestFont(style: .body)
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
