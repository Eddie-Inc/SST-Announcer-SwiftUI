//
//  ContentView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import PostManager

struct ContentView: View {
    @AppStorage("tabSelection") var selection: Int = 0

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                AnnouncementsHomeView()
            }
            .tabItem {
                Label("Announcements", systemImage: "list.bullet")
            }
            .tag(0)

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar.day.timeline.left")
                }
                .tag(1)

            NavigationView {
                Settings()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .onChange(of: selection) { newValue in
            Log.info("Selection: \(newValue)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
