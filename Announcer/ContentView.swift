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
                Label("Test", systemImage: "circle")
            }
        }
        .onAppear {
            Log.info("TEST")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
