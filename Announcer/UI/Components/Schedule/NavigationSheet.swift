//
//  NavigationSheet.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI

struct NavigationSheet<C: View, L: View>: View {
    var content: () -> C
    var label: () -> L

    @State var showingSheet: Bool = false

    init(@ViewBuilder content: @escaping () -> C,
         @ViewBuilder label: @escaping () -> L) {
        self.content = content
        self.label = label
    }

    init(_ label: @escaping @autoclosure () -> String,
         @ViewBuilder content: @escaping () -> C) where L == Text {
        self.content = content
        self.label = { Text(label()) }
    }

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            label()
        }
        .foregroundColor(.primary)
        .sheet(isPresented: $showingSheet) {
            content()
        }
    }
}

struct NavigationSheet_Previews: PreviewProvider {
    static var previews: some View {
        List {
            NavigationSheet("Test 1") {
                Text("Test 1")
            }
            NavigationSheet {
                Text("Test 2")
            } label: {
                HStack {
                    Image(systemName: "circle.fill")
                    Text("Test 2")
                }
            }
        }
    }
}
