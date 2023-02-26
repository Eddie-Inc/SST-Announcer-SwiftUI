//
//  LargeListHeader.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import SwiftUI

struct LargeListHeader: View {
    @State var image: Image
    @State var title: String
    @State var detailText: String?

    var body: some View {
        Section {
            VStack {
                image
                    .foregroundColor(.accentColor)
                    .font(.largeTitle)
                    .scaleEffect(.init(2))
                    .padding(.bottom, 30)
                    .padding(.top, 20)
                Text(title)
                    .font(.title)
                    .bold()
                    .padding(.bottom, 20)
                if let detailText {
                    Text(detailText)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.listBackground)
        }
    }
}

struct LargeListHeader_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LargeListHeader(image: Image(systemName: "calendar.badge.clock"),
                            title: "Timetable",
                            detailText: "Provide your timetable for Announcer to display your daily and next subject")
        }
    }
}
