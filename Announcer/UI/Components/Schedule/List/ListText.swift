//
//  ListText.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import Updating

struct ListText: View {
    @Updating var label: String
    @Updating var value: String?
    @Updating var boldLabel: Bool
    @Updating var grayValue: Bool

    init(_ label: String,
         value: String?,
         boldLabel: Bool = false,
         grayValue: Bool = true) {
        self._label = <-label
        self._value = <-value
        self._boldLabel = <-boldLabel
        self._grayValue = <-grayValue
    }

    var body: some View {
        HStack {
            // .bold(_ isActive:) is only available in iOS 16, so this has to do.
            if boldLabel {
                Text(label)
                    .bold()
                    .multilineTextAlignment(.leading)
            } else {
                Text(label)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            if let value {
                Text(value)
                    .foregroundColor(grayValue ? .gray : nil)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

struct ListText_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListText("Test", value: "Test ABC")
        }
    }
}
