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

    @Environment(\.widgetFamily) var family

    let entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            TimeTableSmall(today: entry.date)
        case .systemMedium:
            TimeTableMedium(today: entry.date)
        case .systemLarge:
            TimeTableLarge(today: entry.date)
        default:
            Text("Unsupported")
        }
    }
}
struct Timetable_Announcer: Widget {
    let kind: String = "Timetable_Announcer"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Timetable_AnnouncerEntryView(entry: entry)
        }
        .configurationDisplayName("Schedule")
        .description("This displays your current schedule")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Timetable_Announcer_Previews: PreviewProvider {
    static var previews: some View {
        Timetable_AnnouncerEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
