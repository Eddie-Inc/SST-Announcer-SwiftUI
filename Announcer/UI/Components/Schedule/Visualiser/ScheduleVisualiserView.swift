//
//  ScheduleVisualiserView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 15/2/23.
//

import SwiftUI
import Chopper
import Updating

struct ScheduleVisualiserView<Provider: ScheduleProvider>: View {
    @Updating var scheduleSuggestion: Provider
    @Updating var week: Week?

    @State var dayHeight: Int = 40
    @State var blockWidth: Int = 25

    @State var font: Font = .footnote

    @State var magnification: CGFloat = 0.4
    @State var initialMagnification: CGFloat = 0.4

    var body: some View {
        VStack {
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack {
                    scrollContent
                        .padding(.vertical, 10)
                        .frame(width: CGFloat(dayHeight *
                                              scheduleSuggestion.timeRange.count * 2/3) * magnification,
                               height: CGFloat(dayHeight * 10) * magnification)
                }
                .scaleEffect(.init(magnification))
            }
            .frame(height: CGFloat(dayHeight * 10) * 0.4)
            if scheduleSuggestion.loadProgress == .loading {
                ProgressView(value: scheduleSuggestion.loadAmount)
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    magnification = initialMagnification * value
                }
                .onEnded { _ in
                    initialMagnification = magnification
                }
        )
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    magnification = 0.4
                    initialMagnification = 0.4
                }
            } label: {
                Image(systemName: "house")
            }
            .buttonStyle(.plain)
            .padding(4)
            .background {
                Color.background
            }
        }
    }

    var scrollContent: some View {
        VStack {
            if let week {
                ForEach(DayOfWeek.allCases) { day in
                    viewFor(week: week, day: day)
                }
            } else {
                ForEach(Week.allCases) { week in
                    ForEach(DayOfWeek.allCases) { day in
                        viewFor(week: week, day: day)
                    }
                }
            }
        }
    }

    func viewFor(week: Week, day: DayOfWeek) -> some View {
        ZStack(alignment: .leading) {
            Color.white.opacity(0.001)
                .frame(width: CGFloat(dayHeight *
                                      scheduleSuggestion.timeRange.count * 2/3),
                       height: 10)
            ForEach(0..<scheduleSuggestion.subjects.count, id: \.self) { index in
                if scheduleSuggestion.subjects[index].day == .init(week: week, day: day) {
                    SubjectVisualiserView(subject: scheduleSuggestion.subjects[index],
                                          dayHeight: dayHeight,
                                          blockWidth: blockWidth,
                                          font: font)
                    .padding(.vertical, -4)
                    .offset(x: CGFloat(blockWidth * scheduleSuggestion.subjects[index]
                        .timeBlocks.lowerBound))
                }
            }
        }
    }
}
