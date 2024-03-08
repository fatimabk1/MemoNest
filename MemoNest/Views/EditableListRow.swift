//
//  EditableListRow.swift
//  MemoNest
//
//  Created by Fatima Kahbi on 3/8/24.
//

import SwiftUI

final class EditableListRowViewModel {
    @State var name: String
    
    init(name: String = "") {
        self.name = name
    }
}

struct EditableListRow: View {
    let icon: String
    var viewModel: EditableListRowViewModel
    
    init(name: String, icon: String) {
        self.viewModel = EditableListRowViewModel(name: name)
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            TextField("Enter folder name", text: viewModel.$name)
                .font(.title)
        }
        .padding()
        Spacer()
    }
}

#Preview{
    let name = "Starting Folder Name"
    return EditableListRow(name: name, icon: "Folder")
}
