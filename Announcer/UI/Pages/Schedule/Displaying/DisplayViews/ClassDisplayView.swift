//
//  ClassDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI
import Chopper

struct ClassDisplayView: View {
    @State var subClass: SubjectClass

    var body: some View {
        HStack {
            ZStack {
                subClass.color
                    .opacity(0.5)
                ListText(subClass.name.description,
                         value: subClass.teacher,
                         boldLabel: true,
                         grayValue: false)
                .padding(.horizontal, 10)
            }
            .cornerRadius(5)
        }
        .padding(.vertical, 1)
        .padding(.leading, -10)
        .listRowSeparator(.hidden)
    }
}

struct ClassDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                NavigationLink {
                    Text("Test")
                } label: {
                    ClassDisplayView(subClass: .init(name: .some("Chinese"), color: .purple))
                }
                NavigationLink {
                    Text("Test")
                } label: {
                    ClassDisplayView(subClass: .init(name: .some("English"), teacher: "Noor", color: .blue))
                }
            }
        }
    }
}
