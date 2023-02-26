//
//  ListTextField.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import Updating

struct ListTextField: View {
    @Updating var label: String
    @Binding var value: String

    init(_ label: String, value: Binding<String>) {
        self._label = <-label
        self._value = value
    }

    var body: some View {
        HStack {
            HStack {
                Text(label)
                TextField("", text: $value)
                .multilineTextAlignment(.trailing)
            }
        }
    }
}
