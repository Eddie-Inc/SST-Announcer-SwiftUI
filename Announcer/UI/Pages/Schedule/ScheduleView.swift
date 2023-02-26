//
//  ScheduleView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import PostManager // for exists

struct ScheduleView: View {
    @State var showProvideSchedule: Bool = false
    @State var scheduleExists: Bool = exists(file: "schedule")
    @State var refresherID: Int = 0 // used to refresh the schedule display view

    init() {
        if !scheduleExists {
            self._showProvideSchedule = State(wrappedValue: true)
        }
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
            scheduleExists = exists(file: "schedule")
            refresherID += 1
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
    }
}
