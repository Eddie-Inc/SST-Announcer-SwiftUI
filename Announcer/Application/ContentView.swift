//
//  ContentView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import PostManager
import Chopper

struct ContentView: View {
    @AppStorage("tabSelection") var selection: Int = 0

    @State var proposalSchedule: ScheduleConfirmation?

    @ObservedObject
    var settings: SettingsManager = .shared

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                AnnouncementsHomeView()
            }
            .tabItem {
                Label("Announcements", systemImage: "list.bullet")
            }
            .tag(0)

            if settings.showSchedule {
                ScheduleView()
                    .tabItem {
                        Label("Schedule", systemImage: "calendar.day.timeline.left")
                    }
                    .tag(1)
            }

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
        .onOpenURL { url in
            print("Asked to open URL: \(url.description)")

            guard let scheme = url.scheme,
                  scheme.localizedCaseInsensitiveCompare("announcer") == .orderedSame
            else { return }

            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }

            guard url.host == "schedule",
                  let source = parameters["source"],
                  let decodedSchedule = decodeString(string: source)
            else {
                print("Could not decode schedule")
                return
            }

            // detect if it is a copy of a schedule they already have
            if let matchingSchedule = ScheduleManager.default.schedules.first(where: {
                $0.id == decodedSchedule.id || $0.name == decodedSchedule.name
            }) {
                proposalSchedule = .idMatchesAskForConfirmation(decodedSchedule, matchingSchedule)
                print("Schedule has dupe")
            } else {
                proposalSchedule = .askForConfirmation(decodedSchedule)
                print("Schedule no dupe")
            }
            selection = 1
        }
        .sheet(item: $proposalSchedule) { proposal in
            ScheduleConfirmationView(scheduleConfirmation: proposal,
                                     showProvideSuggestion: .constant(true))
            .onAppear {
                print("Proposal appeared!")
            }
        }
    }

    func decodeString(string: String) -> Schedule? {
        print("String: \(string)")
        guard let stringData = string.data(using: .utf8),
              let data = Data(base64Encoded: stringData),
              let uncompressed = try? (data as NSData).decompressed(using: .lzfse)
        else {
            print("Could not get string data, data, or uncompressed")
            return nil
        }

        print("Uncompressed data: \(uncompressed.description)")
        if let result = String(data: uncompressed as Data, encoding: .utf8) {
            print("Data contents: \(result)")
        }

        guard let schedule = try? JSONDecoder().decode(Schedule.self, from: uncompressed as Data)
        else {
            print("Could not get schedule")
            return nil
        }

        return schedule
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
