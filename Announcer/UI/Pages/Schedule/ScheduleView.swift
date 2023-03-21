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

    @State var showProvideSchedule: Bool = false
    @State private var showProvideScheduleLastValue: Bool = false
    @State var refresherID: Int = 0 // used to refresh the schedule display view

    @StateObject var manager: ScheduleManager

    @State var managerSink: AnyCancellable?

    @State var showScheduleFAQ: Bool = false

    init() {
        let manager = ScheduleManager.default
        if let _ = manager.currentSchedule {} else {
            self._showProvideSchedule = State(wrappedValue: true)
            self._showProvideScheduleLastValue = State(wrappedValue: true)
        }

        self._manager = .init(wrappedValue: manager)
    }

    var body: some View {
        NavigationView {
            if !showProvideSchedule {
                ScheduleDisplayView()
                    .id(refresherID)
            } else {
                ProvideScheduleView(showProvideSuggestion: $showProvideSchedule)
            }
        }
        .sheet(isPresented: $showScheduleFAQ) {
            ScheduleFAQView()
        }
        .onChange(of: showProvideSchedule) { newValue in
            if newValue == false && showProvideScheduleLastValue == true {
                // schedule provided!
                showScheduleFAQ = true
            }
            showProvideScheduleLastValue = newValue

            manager.fetchSchedules()
            if let _ = manager.currentSchedule {
                refresherID += 1
            }
        }
        .onAppear {
            managerSink = manager.$currentSchedule.sink { newValue in
                showProvideSchedule = newValue == nil
            }
        }
    }
}
