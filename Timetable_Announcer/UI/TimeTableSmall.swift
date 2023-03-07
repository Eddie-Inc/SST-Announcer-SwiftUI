//
//  TimeTableSmall.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/3/23.
//

import SwiftUI
import Chopper
import Updating

struct TimeTableSmall: TimeTableProtocol {
    @ObservedObject
    var manager: ScheduleManager = .default

    @Updating
    var today: Date

    var body: some View {
        VStack {
            Text(today.formatted(date: .abbreviated, time: .shortened))
            Text("Small")
        }
    }
}

struct TimeTableSmall_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableSmall(today: .now)
            .frame(width: 155, height: 155)
            .border(.black, width: 1)
    }
}
