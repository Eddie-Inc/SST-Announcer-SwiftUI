//
//  ScheduleView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import Chopper
import Combine

struct ScheduleView: View {
    @State var scheduleExists: Bool

    @State var showProvideSchedule: Bool = false
    @State var refresherID: Int = 0 // used to refresh the schedule display view

    @StateObject var manager: ScheduleManager

    @State var managerSink: AnyCancellable?

    init() {
        let manager = ScheduleManager.default
        let scheduleExists: Bool
        if let _ = manager.currentSchedule {
            scheduleExists = true
        } else {
            scheduleExists = false
            self._showProvideSchedule = State(wrappedValue: true)
        }

        self._scheduleExists = .init(wrappedValue: scheduleExists)
        self._manager = .init(wrappedValue: manager)
    }

    var body: some View {
        NavigationView {
            if scheduleExists && !showProvideSchedule {
                ScheduleDisplayView()
                    .id(refresherID)
            } else {
                ProvideScheduleView(showProvideSuggestion: $showProvideSchedule)
            }
        }
        .onChange(of: showProvideSchedule) { _ in
            print("Show provide schedule changed")
            manager.fetchSchedules()
            if let _ = manager.currentSchedule {
                refresherID += 1
            }
        }
        .onAppear {
            managerSink = manager.$currentSchedule.sink { newValue in
                print("Manager sink changed")
                self.scheduleExists = newValue != nil
                showProvideSchedule = !scheduleExists
                print("Schedule exists: \(scheduleExists)")
            }
        }
    }
}
