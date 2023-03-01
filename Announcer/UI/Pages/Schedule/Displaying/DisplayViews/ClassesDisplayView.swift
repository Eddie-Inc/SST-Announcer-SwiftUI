//
//  ClassesDisplayView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 25/2/23.
//

import SwiftUI
import Updating
import Chopper

struct ClassesDisplayView: View {
    @State var schedule: Schedule // no need to be updating for this one
    @State var searchString: String = ""

    var body: some View {
        List {
            ForEach(schedule.subjectClasses) { subClass in
                if shouldBeShown(subClass: subClass) {
                    NavigationLink {
                        OtherSubjectInstancesView(schedule: schedule,
                                                  subClass: subClass,
                                                  showVisualiser: true)
                    } label: {
                        if #available(iOS 16.0, *) {
                            ClassDisplayView(subClass: subClass)
                                .contextMenu {
                                    Button("Copy Details") {
                                    }
                                } preview: {
                                    OtherSubjectInstancesView(schedule: schedule,
                                                              subClass: subClass,
                                                              showVisualiser: false)
                                }
                        } else {
                            ClassDisplayView(subClass: subClass)
                                .contextMenu {
                                    Button("Copy Details") {
                                    }
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Classes")
        .searchable(text: $searchString)
    }

    func shouldBeShown(subClass: SubjectClass) -> Bool {
        guard !searchString.isEmpty else { return true }
        let lowerSearch = searchString.lowercased()

        let teacherMatches = subClass.teacher?.lowercased().contains(lowerSearch) ?? false
        let nameMatches = subClass.name.description.lowercased().contains(lowerSearch)

        return teacherMatches || nameMatches
    }
}
