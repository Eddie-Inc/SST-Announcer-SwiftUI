//
//  ProvideScheduleView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import SwiftUI
import Chopper

struct ProvideScheduleView: View {
    @State var image: UIImage?
    @State var schedule: ScheduleSuggestion?

    @Binding var showProvideSuggestion: Bool

    var body: some View {
        List {
            LargeListHeader(image: Image(systemName: "calendar.badge.clock"),
                            title: "Timetable",
                            detailText: "Provide your timetable for Announcer to display your daily and next subject")

            Section {
                NavigationSheet {
                    ImagePicker(image: $image)
                } label: {
                    Text("Choose Image")
                        .foregroundColor(.accentColor)
                }

                if let image = schedule?.processedSource.image {
                    ScrollView(.vertical, showsIndicators: true) {
                        Text("Processed Schedule:")
                            .font(.subheadline)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(maxHeight: 300)
                } else if let image {
                    ScrollView(.vertical, showsIndicators: true) {
                        Text("Failed to process image. \nThe image may have a too low resolution.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(maxHeight: 300)
                }
            }

            Section {
                NavigationLink {
                    VStack {
                        if let schedule {
                            ScheduleSuggestionView(scheduleSuggestion: schedule,
                                                   showProvideSuggestion: $showProvideSuggestion)
                        }
                    }
                } label: {
                    HStack {
                        if let schedule, schedule.loadProgress != .loaded {
                            Text("Loading")
                            ProgressView(value: schedule.loadAmount)
                        } else {
                            Text("Continue")
                            Spacer()
                        }
                    }
                }
                .disabled(schedule == nil || schedule?.loadProgress != .loaded)
            }
        }
        .onChange(of: image) { newValue in
            guard let image else {
                schedule = nil
                return
            }
            schedule = .init(sourceImage: image)
            if let schedule {
                schedule.loadSubjectTexts { newValue in
                    // make sure the operation wasn't cancelled
                    if self.schedule?.id == newValue.id {
                        self.schedule = newValue
                        self.schedule?.loadClasses()
                    }
                }
            }
        }
    }
}

struct ProvideScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ProvideScheduleView(showProvideSuggestion: .constant(true))
    }
}

extension Color {
    static let background: Color = .init(uiColor: .systemBackground)
    static let listBackground: Color = .init(uiColor: .systemGroupedBackground)
}
