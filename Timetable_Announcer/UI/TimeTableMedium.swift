//
//  TimeTableMedium.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/3/23.
//

import SwiftUI
import Chopper
import Updating

struct TimeTableMedium: View {
    @ObservedObject
    var manager: ScheduleManager = .default

    @Updating
    var today: Date

    var body: some View {
        VStack {
            Text(today.formatted(date: .abbreviated, time: .shortened))
            Text("Medium")
        }
    }
}

struct TimeTableMedium_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableMedium(today: .now)
            .frame(width: 329, height: 155)
            .border(.black, width: 1)
    }
}
