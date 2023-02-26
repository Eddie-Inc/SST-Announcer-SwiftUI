//
//  ContentView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                AnnouncementsHomeView()
            }
            .tabItem {
                Label("Announcements", systemImage: "list.bullet")
            }

            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar.day.timeline.left")
                }

            NavigationView {
                Settings()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
