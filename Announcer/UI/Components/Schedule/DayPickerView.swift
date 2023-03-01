//
//  DayPickerView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 1/3/23.
//

import SwiftUI
import Chopper
import Updating

struct DayPickerView: View {
    @Binding var selection: Day
    @Updating var schedule: Schedule

    @State var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geom in
            HStack {
                viewForWeek(week: .odd, geom: geom)
                    .id("odd")
                    .padding(.trailing, -4)
                viewForWeek(week: .even, geom: geom)
                    .id("even")
                    .padding(.leading, -4)
            }
            .frame(width: geom.size.width * 2)
            .offset(x: geom.size.width * (selection.week == .odd ? 0 : -1) + offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.offset = value.location.x - value.startLocation.x
                    }
                    .onEnded { _ in
                        let cutoff = geom.size.width * 1/3
                        if abs(self.offset) > cutoff {
                            flipWeek()
                        }
                        withAnimation {
                            self.offset = 0
                        }
                    }
            )
        }
        .overlay {
            HStack {
                Button {
                    flipWeek()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(selection.week == .odd ? .gray : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(selection.week == .odd)
                Spacer()
                Button {
                    flipWeek()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(selection.week == .even ? .gray : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(selection.week == .even)
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 30)
    }

    func viewForWeek(week: Week, geom: GeometryProxy) -> some View {
        HStack {
            Spacer().frame(width: 20)
            Text(week.rawValue.firstLetterUppercase)
                .font(.subheadline)
                .frame(width: 50)
            Spacer()
            ForEach(sortedDays.filter({ $0.week == week })) { day in
                Text(day.day.rawValue.first!.uppercased())
                    .foregroundColor(selection == day ? .background : .primary)
                    .frame(width: 24, height: 24)
                    .background {
                        if selection == day {
                            Color.blue
                                .cornerRadius(6)
                        } else {
                            Color.white.opacity(0.001)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .frame(width: 40)
                    .onTapGesture {
                        withAnimation {
                            self.selection = day
                        }
                    }
            }
            Spacer().frame(width: 20)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
    }

    var sortedDays: [Day] {
        // create all possible days, then sort them
        var days: [Day] = []
        for week in Week.allCases {
            for day in DayOfWeek.allCases {
                days.append(.init(week: week, day: day))
            }
        }
        return days
    }

    // flips odd to even and vice versa
    func flipWeek(animate: Bool = true) {
        var newValue = selection.week
        switch selection.week {
        case .odd: newValue = .even
        case .even: newValue = .odd
        }
        if animate {
            withAnimation {
                self.selection.week = newValue
            }
        } else {
            self.selection.week = newValue
        }
    }
}
