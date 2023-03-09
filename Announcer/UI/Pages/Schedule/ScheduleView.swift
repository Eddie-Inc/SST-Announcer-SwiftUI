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
        let scheduleExists = manager.hasScheduleInStorage
        if !scheduleExists {
            self._showProvideSchedule = State(wrappedValue: true)
        }

        self.scheduleExists = scheduleExists
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
            manager.fetchSchedule()
            if manager.currentSchedule != nil {
                refresherID += 1
            }
        }
        .onAppear {
            managerSink = manager.objectWillChange.sink {
                print("Manager sink changed")
                self.scheduleExists = manager.currentSchedule != nil
                showProvideSchedule = !scheduleExists
                print("Schedule exists: \(scheduleExists)")
            }
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
