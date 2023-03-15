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

    @Binding var showInfo: Bool
    @Binding var showProvideSchedule: Bool

    @State var idToDelete: UUID?

    var body: some View {
        List {
            Section {
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            idToDelete = schedule.id
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
                .onDelete { indexSet in
                    let schedulesToDelete = indexSet.map { manager.schedules[$0] }
                    for toDelete in schedulesToDelete {
                        manager.removeSchedule(id: toDelete.id)
                    }
                }
            }

            Section {
                Button("Add new schedule") {
                    showInfo = false
                    showProvideSchedule = true
                }
            }
        }
        .alert(item: $idToDelete) { id in
            Alert(title: Text("Are you sure you want to delete schedule \"\(manager.schedules.first(where: { $0.id == id })?.name ?? "untitled")\"?"),
                  message: Text("You cannot undo this action"),
                  primaryButton: .default(Text("Delete"), action: {
                manager.removeSchedule(id: id)
            }),
                  secondaryButton: .cancel(Text("Cancel")))
        }
    }
}

extension UUID: Identifiable {
    public var id: UUID { self }
}
