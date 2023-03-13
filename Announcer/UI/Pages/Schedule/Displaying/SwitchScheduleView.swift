//
//  SwitchScheduleView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 14/3/23.
//

import SwiftUI
import Chopper

struct SwitchScheduleView: View {
    @ObservedObject var manager: ScheduleManager = .default

    var body: some View {
        List {
            ForEach(manager.schedules) { schedule in
                HStack {
                    Image(systemName: "checkmark")
                        .opacity(schedule == manager.currentSchedule ? 1 : 0)
                    Text(schedule.name ?? "Untitled")
                    Spacer()
                    Text(schedule.startDate.formatted(date: .numeric, time: .omitted) + "\n" +
                         schedule.endDate.formatted(date: .numeric, time: .omitted))
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
