//
//  Timetable_Announcer.swift
//  Timetable_Announcer
//
//  Created by Ayaan Jain on 6/3/23.
//

import WidgetKit
import SwiftUI
import Intents
import Chopper

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct Timetable_AnnouncerEntryView : View {
    let entry: Provider.Entry
    
    init() {
        let manager = ScheduleManager.default
        let today = Date.now
        self._day = State(wrappedValue: .init(week: manager.schedule.currentWeek%2 == 0 ? .even : .odd,
                                              day: today.weekday.dayOfWeek ?? .monday))
    }
    @State var compactTop: Bool = true
    @State var day: ScheduleDay //Get current day
    @ObservedObject var manager: ScheduleManager = .default //Get the file from Chopper so I can use the module
    @State var today: Date = .now //Get the current date
    
    var todayValue: ScheduleDay {
        let todayDay = today.weekday.dayOfWeek ?? .monday
        return ScheduleDay(week: manager.schedule.currentWeek%2 == 0 ? .even : .odd,
                           day: todayDay)
    }
    var isCurrentDay: Bool {
        // if the day of week is nil, its always false.
        guard today.weekday.dayOfWeek != nil else { return false }
        return day.description == todayValue.description
    }
    
    //Get the current subject:
    func indexOfCurrentSubject(day: ScheduleDay) -> Int {
        guard isCurrentDay else { return -1 }

        let subjects = manager.schedule.subjectsMatching(day: day.day, week: day.week)
        let todayTime = today.timePoint

        // during available subjects
        if let index = subjects.firstIndex(where: { $0.contains(time: todayTime) }) {
            print("Current subject for \(day.description): \(index)")
            return index
        }

        // before start
        if let start = subjects.first?.timeRange.lowerBound, start > todayTime {
            print("Current subject for \(day.description): before")
            return -1
        }

        // after end
        if let end = subjects.last?.timeRange.upperBound, end < todayTime {
            print("Current subject for \(day.description): after \(subjects.count)")
            return subjects.count
        }

        // default to before start
        print("Current subject for \(day.description): defaulting to -1")
        return -1
    }
    
    var body: some View {
        HStack{
            if indexOfCurrentSubject(day: day) > 3 && compactTop {
                HStack {
                    HStack {
                        ForEach(0..<min(3, indexOfCurrentSubject(day: day) - 3), id: \.self) { index in
                            manager.schedule.subjectsMatching(day: day.day, week: day.week)[index]
                                .displayColor
                                .frame(width: 10, height: 25)
                                .cornerRadius(5)
                        }
                    }
                    .mask(alignment: .leading) {
                        LinearGradient(stops: [
                            .init(color: .white, location: 0.2),
                            .init(color: .clear, location: 1)
                        ],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                        .frame(width: 50)
                    }
                    Text("\(indexOfCurrentSubject(day: day) - 3) subjects")
                        .padding(.horizontal, 5)
                        .font(.subheadline)
                    Spacer()
                }
                .onTapGesture {
                    withAnimation {
                        compactTop = false
                    }
                }
                .listRowInsets(.init(top: 5,
                                     leading: 8,
                                     bottom: 5,
                                     trailing: 8))
                .listRowSeparator(.hidden)
            }
        }
    }
}
struct Timetable_Announcer: Widget {
    let kind: String = "Timetable_Announcer"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Timetable_AnnouncerEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Timetable_Announcer_Previews: PreviewProvider {
    static var previews: some View {
        Timetable_AnnouncerEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
