//
//  ScheduleView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import Chopper

struct ScheduleView: View {
    @State var scheduleExists: Bool

    @State var showProvideSchedule: Bool = false
    @State var refresherID: Int = 0 // used to refresh the schedule display view

    @StateObject var manager: ScheduleManager

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
            if scheduleExists || !showProvideSchedule {
                ScheduleDisplayView()
                    .id(refresherID)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(isActive: $showProvideSchedule) {
                                ProvideScheduleView(showProvideSuggestion: $showProvideSchedule)
                            } label: {
                                Image(systemName: "calendar.badge.plus")
                            }
                        }
                    }
            } else {
                ProvideScheduleView(showProvideSuggestion: $showProvideSchedule)
            }
        }
        .onChange(of: showProvideSchedule) { _ in
            manager.fetchSchedule()
            refresherID += 1
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
