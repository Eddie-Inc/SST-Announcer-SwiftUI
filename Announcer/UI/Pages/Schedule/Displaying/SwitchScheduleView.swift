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

    init() {
        print("Current schedule: \(manager.currentSchedule.id)")
        print("IDs: \(manager.schedules.map({ $0.id.uuidString }))")
    }

    var body: some View {
        List {
            ForEach(manager.schedules) { schedule in
                Button {
                    manager.switchSchedule(to: schedule.id)
                } label: {
                    HStack {
                        Image(systemName: "checkmark")
                            .opacity(schedule.id == manager.currentSchedule.id ? 1 : 0)
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
}
