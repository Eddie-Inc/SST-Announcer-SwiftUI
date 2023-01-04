//
//  EditFilterView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 4/1/23.
//

import SwiftUI

struct EditFilterView: View {

    @State
    var possibleTags: [(name: String, isActive: Bool)] = [
        ("Test", false),
        ("Another test", true)
    ]

    var body: some View {
        List {
            ForEach($possibleTags, id: \.0) { $tag in
                Button {
                    tag.1.toggle()
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                            .opacity(tag.1 ? 1 : 0)
                        Text(tag.0)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

struct EditFilterView_Previews: PreviewProvider {
    static var previews: some View {
        EditFilterView()
    }
}
