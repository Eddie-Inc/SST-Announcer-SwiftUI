//
//  SubjectSuggestionEditView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 16/2/23.
//

import SwiftUI
import Chopper

struct SubjectSuggestionEditView<Table: ScheduleProvider, Block: TimeBlock>: View where Block == Table.Block {
    @Binding var suggestion: Block
    @Binding var schedule: Table

    @State var showAssignClassSheet: Bool = false
    @State var showMatchingSubs: Bool = false
    @State var subsToMatch: [UUID]?

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        infoList
            .sheet(isPresented: $showAssignClassSheet) {
                NavigationView {
                    if #available(iOS 16.0, *) {
                        ChangeSubjectView(suggestion: $suggestion,
                                          schedule: $schedule,
                                          showAssignClassSheet: $showAssignClassSheet,
                                          showMatchingSubs: $showMatchingSubs,
                                          subsToMatch: $subsToMatch)
                            .presentationDetents([.medium, .large])
                    } else {
                        ChangeSubjectView(suggestion: $suggestion,
                                          schedule: $schedule,
                                          showAssignClassSheet: $showAssignClassSheet,
                                          showMatchingSubs: $showMatchingSubs,
                                          subsToMatch: $subsToMatch)
                    }
                }
            }
    }

    var infoList: some View {
        List {
            if let suggestion = suggestion as? SubjectSuggestion {
                Section("Original Image") {
                    Image(uiImage: suggestion.image)
                }
            }

            Section("Subject Information") {
                if suggestion is ScheduleSuggestion {
                    ListText("Inferred Name", value: suggestion.displayName?.description ?? "none")

                    ListText("Inferred Teacher", value: suggestion.displaySubtext ?? "none")
                }

                timingInfo
            }

            Section("Class Information") {
                classInfo
            }
            .onChange(of: suggestion.displaySubjectClass) { _ in
                if let subClass = suggestion.displaySubjectClass {
                    schedule.updateClass(subClass: subClass)
                }
            }

            Section {
                subjectActions
            }
        }
        .navigationTitle(subjectName + " (" + suggestion.timeRangeDescription() + ")")
        .alert("Assign class to all similar subjects?", isPresented: $showMatchingSubs) {
            if let subsToMatch {
                Button("Assign \(subsToMatch.count) subjects") {
                    for id in subsToMatch {
                        guard let index = (schedule.subjects as? [SubjectSuggestion])?.firstIndex(where: {
                            $0.id == id
                        }) else { continue }
                        schedule.subjects[index].displaySubjectClass = suggestion.displaySubjectClass
                    }

                    schedule.trimUnusedClasses()
                }
            }
            Button("Don't assign") {}
        } message: {
            if let subsToMatch {
                Text("\(subsToMatch.count) unassigned subjects were found with the name ") +
                Text(suggestion.displaySubjectClass?.name.description ?? "None")
            }
        }
    }

    @ViewBuilder
    var timingInfo: some View {
        Picker("Start Time", selection: .init(get: {
            suggestion.timeBlocks.lowerBound
        }, set: { newValue in
            guard newValue+suggestion.timeBlocks.count < schedule.timeRange.upperBound else { return }
            assignNewTime(newTime: newValue..<newValue+suggestion.timeBlocks.count)
        })) {
            ForEach(schedule.timeRange, id: \.self) { index in
                // if its valid
                if index+suggestion.timeBlocks.count < schedule.timeRange.upperBound &&
                    isNewTimeValid(timeBlocks: index..<index+suggestion.timeBlocks.count) {
                    Text(timeFor(blocks: index))
                        .tag(index)
                }
            }
        }
        .pickerStyle(.menu)

        Picker("End Time", selection: .init(get: {
            suggestion.timeBlocks.upperBound
        }, set: { newValue in
            guard newValue > suggestion.timeBlocks.lowerBound else { return }
            assignNewTime(newTime: suggestion.timeBlocks.lowerBound..<newValue)
        })) {
            ForEach(schedule.timeRange, id: \.self) { index in
                // if its valid
                if suggestion.timeBlocks.lowerBound < index &&
                    isNewTimeValid(timeBlocks: suggestion.timeBlocks.lowerBound..<index) {
                    Text(timeFor(blocks: index))
                        .tag(index)
                }
            }
        }
        .pickerStyle(.menu)

        ListText("Duration", value: suggestion.durationFormatted())
    }

    @ViewBuilder
    var classInfo: some View {
        if let subClass = suggestion.displaySubjectClass {
            ColorPicker("Color",
                        selection: .init(get: { subClass.color },
                                         set: { suggestion.displaySubjectClass?.color = $0 }),
                        supportsOpacity: false)
            ListTextField("Name", value: .init(get: { subClass.name.description },
                                               set: { suggestion.displaySubjectClass?.name = .some($0) }))
            ListTextField("Teacher", value: .init(get: { subClass.teacher ?? "" },
                                                  set: { newTeacher in
                suggestion.displaySubjectClass?.teacher = newTeacher.isEmpty ? nil : newTeacher
            }))
            Button("Change Class") {
                showAssignClassSheet = true
            }
        } else {
            Button {
                showAssignClassSheet = true
            } label: {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                    Text("Assign to Class")
                }
            }
        }
    }

    @ViewBuilder
    var subjectActions: some View {
        Button("Delete Subject", role: .destructive) {
            schedule.subjects.removeAll(where: { $0 == suggestion })
            schedule.trimUnusedClasses()
            presentationMode.wrappedValue.dismiss()
        }

        // two hour block. May have been two one-hour blocks, misclassified.
        if suggestion.timeBlocks.count == 6 {
            Button(role: .destructive) {
                splitSubject()
            } label: {
                VStack(alignment: .leading) {
                    Text("Split into two subjects")
                    Text("""
Sometimes, two-hour long subjects may have alternatives as two different one-hour subjects, especially in S3 and S4.
Press this button to split this subject into two subjects.
""")
                    .font(.footnote)
                }
            }
        }
    }

    var subjectName: String {
        suggestion.displaySubjectClass?.name.description ?? suggestion.displayName?.description ?? "Untitled"
    }
}

extension SubjectSuggestionEditView {

    func timeFor(blocks: Int, minutesPerBlock: Int = 20, startingAt: Int = 0800) -> String {
        let startingMinutes = (startingAt/100 * 60) + startingAt%100
        let totalMinutes = startingMinutes + minutesPerBlock * (blocks-1)
        let hours = totalMinutes / 60
        let minutes = totalMinutes - (hours * 60)

        let formattedString = String(format: "%02d", hours) + ":" + String(format: "%02d", minutes)

        return formattedString
    }

    func assignNewTime(newTime: Range<Int>) {
        guard isNewTimeValid(timeBlocks: newTime) else { return }
        suggestion.timeBlocks = newTime

        // make sure subjects are in order
        DispatchQueue.main.async {
            schedule.sortClasses()
        }
    }

    func isNewTimeValid(timeBlocks: Range<Int>) -> Bool {
        // iterate over all other subjects, and make sure theres no conflicts
        for subject in schedule.subjects.filter({ $0.day == suggestion.day }) {
            guard subject != suggestion, subject.timeBlocks.overlaps(timeBlocks) else { continue }

            return false
        }
        return true
    }

    func splitSubject() {
        if let suggestion = suggestion as? SubjectSuggestion {
            splitSubjectSuggestion(suggestion: suggestion)
        } else if let suggestion = suggestion as? Subject {
            splitSubjectFinal(suggestion: suggestion)
        }
    }

    func splitSubjectFinal(suggestion: Subject) {
        // determine the times
        let midBound = suggestion.timeBlocks.lowerBound + suggestion.timeBlocks.count/2
        let lTime = suggestion.timeBlocks.lowerBound..<midBound
        let rTime = midBound..<suggestion.timeBlocks.upperBound

        // create the subjects
        let lSub = Subject(timeBlocks: lTime,
                           day: suggestion.day,
                           subjectClass: suggestion.subjectClass)
        let rSub = Subject(timeBlocks: rTime,
                           day: suggestion.day,
                           subjectClass: suggestion.subjectClass)

        // determine where to add them
        guard let thisSubjectIndex = (schedule.subjects as? [Subject])?.firstIndex(of: suggestion),
              let rBlock = rSub as? Block,
              let lBlock = lSub as? Block
        else { return }
        schedule.subjects.insert(rBlock, at: thisSubjectIndex) // right then left, so that right is after left
        schedule.subjects.insert(lBlock, at: thisSubjectIndex)

        // delete this subject
        schedule.subjects.remove(at: thisSubjectIndex+2) // add two to account for rSub and lSub

        // dismiss this screen
        presentationMode.wrappedValue.dismiss()
    }

    func splitSubjectSuggestion(suggestion: SubjectSuggestion) {
        // split into two subjects
        // first, determine the images for those subjects
        let middleX = Int(suggestion.image.size.width/2)
        guard let cgImage = suggestion.image.cgImage,
              let lImage = cgImage.cropping(to: .init(x: 0, y: 0,
                                                      width: middleX, height: cgImage.height)),
              let rImage = cgImage.cropping(to: .init(x: middleX, y: 0,
                                                      width: cgImage.width-middleX, height: cgImage.height))
        else { return }

        // determine the times
        let midBound = suggestion.timeBlocks.lowerBound + suggestion.timeBlocks.count/2
        let lTime = suggestion.timeBlocks.lowerBound..<midBound
        let rTime = midBound..<suggestion.timeBlocks.upperBound

        // create the subjects
        let lSub = SubjectSuggestion(image: UIImage(cgImage: lImage), timeBlocks: lTime, day: suggestion.day)
        let rSub = SubjectSuggestion(image: UIImage(cgImage: rImage), timeBlocks: rTime, day: suggestion.day)

        // determine where to add them
        guard let thisSubjectIndex = (schedule.subjects as? [SubjectSuggestion])?.firstIndex(of: suggestion),
              let rBlock = rSub as? Block,
              let lBlock = lSub as? Block
        else { return }
        schedule.subjects.insert(rBlock, at: thisSubjectIndex) // right then left, so that right is after left
        schedule.subjects.insert(lBlock, at: thisSubjectIndex)

        // delete this subject
        schedule.subjects.remove(at: thisSubjectIndex+2) // add two to account for rSub and lSub

        // load the subjects
        lSub.load { newVal in
            if let index = schedule.subjects.firstIndex(of: lBlock),
                let newVal = newVal as? Block {
                schedule.subjects[index] = newVal
            }
        }
        rSub.load { newVal in
            if let index = schedule.subjects.firstIndex(of: rBlock),
                let newVal = newVal as? Block {
                schedule.subjects[index] = newVal
            }
        }

        // dismiss this screen
        presentationMode.wrappedValue.dismiss()
    }
}
