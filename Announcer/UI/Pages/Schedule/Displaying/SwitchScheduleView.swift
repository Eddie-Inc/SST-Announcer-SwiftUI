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
            ForEach($manager.schedules) { $schedule in
                HStack {
                    Button {
                        manager.switchSchedule(to: schedule.id)
                    } label: {
                        if schedule.id == manager.currentSchedule.id {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                    .buttonStyle(.plain)
                    TextField("Schedule Name", text: .init(get: {
                        schedule.name ?? "Untitled"
                    }, set: { newValue in
                        schedule.name = newValue
                    }))
                    .onSubmit {
                        manager.saveSchedule(id: schedule.id)
                    }
                    Spacer()
                    Text(schedule.startDate.formatted(date: .numeric, time: .omitted) + "\n" +
                         schedule.endDate.formatted(date: .numeric, time: .omitted))
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
