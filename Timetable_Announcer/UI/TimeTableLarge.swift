//
//  TimeTableLarge.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/3/23.
//

import SwiftUI
import Chopper
import Updating

struct TimeTableLarge: View {
    @ObservedObject
    var manager: ScheduleManager = .default

    @Updating
    var today: Date

    var body: some View {
        VStack {
            Text(today.formatted(date: .abbreviated, time: .shortened))
            Text("Large")
        }
    }
}

struct TimeTableLarge_Previews: PreviewProvider {
    static var previews: some View {
        TimeTableLarge(today: .now)
    }
}
