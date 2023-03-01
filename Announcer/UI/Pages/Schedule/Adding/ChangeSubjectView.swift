//
//  ChangeSubjectView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 26/2/23.
//

import SwiftUI
import Chopper

struct ChangeSubjectView<Table: ScheduleProvider, Block: TimeBlock>: View where Block == Table.Block {
    @Binding var suggestion: Block
    @Binding var schedule: Table

    @Binding var showAssignClassSheet: Bool
    @Binding var showMatchingSubs: Bool
    @Binding var subsToMatch: [UUID]?

    @State var subClassSearchTerm: String = ""

    var body: some View {
        List {
            if subClassSearchTerm.isEmpty {
                Section("Selected") {
                    if let subClass = suggestion.displaySubjectClass {
                        viewForClass(subClass: subClass)
                    } else {
                        Text("None")
                            .italic()
                            .foregroundColor(.gray)
                    }
                }
            } else {
                Section {
                    Button("Create class named \"\(subClassSearchTerm)\"") {
                        newClass(named: subClassSearchTerm)
                    }
                }
            }

            Section {
                ForEach(schedule.subjectClasses) { subClass in
                    if classShouldBeShown(subClass: subClass) {
                        Button {
                            suggestion.displaySubjectClass = subClass
                            // remove all subject classes that no longer exist
                            DispatchQueue.main.async {
                                schedule.trimUnusedClasses()
                            }
                            showAssignClassSheet = false
                        } label: {
                            viewForClass(subClass: subClass)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for toDelete in indexSet.map({ schedule.subjectClasses[$0] }) {
                        schedule.deleteClass(subClass: toDelete)
                    }
                }
            }
        }
        .navigationTitle("Change Class")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    newClass(named: "Untitled")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .searchable(text: $subClassSearchTerm)
    }

    func viewForClass(subClass: SubjectClass) -> some View {
        HStack {
            Circle()
                .fill(subClass.color)
                .frame(width: 20, height: 20)
            if let teacher = subClass.teacher {
                Text("\(subClass.name.description) - \(teacher)")
            } else {
                Text(subClass.name.description)
            }
            Spacer()
            Image(systemName: "checkmark")
                .opacity(suggestion.displaySubjectClass == subClass ? 1 : 0)
        }
    }

    func classShouldBeShown(subClass: SubjectClass) -> Bool {
        // if it is the selected class, don't show it. It goes somewhere else.
        guard subClass != suggestion.displaySubjectClass else { return false }
        // if search is empty, show everything
        guard !subClassSearchTerm.isEmpty else { return true }

        // else, it needs to match.
        let nameMatches = subClass.name.description.lowercased().contains(subClassSearchTerm.lowercased())
        let teacherMatches = subClass.teacher?.lowercased().contains(subClassSearchTerm.lowercased()) ?? false

        return nameMatches || teacherMatches
    }

    func newClass(named name: String) {
        let newClass = SubjectClass(name: .some(name), teacher: nil, color: schedule.colorFor(name: name))

        defer {
            suggestion.displaySubjectClass = newClass
            schedule.subjectClasses.append(newClass)
            showAssignClassSheet = false
        }

        guard let suggestion = suggestion as? SubjectSuggestion,
              let schedule = schedule as? ScheduleSuggestion
        else { return }

        // if unidentified, ask if they want to assign this class to all matching subjects
        if suggestion.displayName == .unidentified {
            let matchingSubjects = schedule.subjects.filter { sub in
                sub != suggestion && sub.displaySubjectClass == nil &&
                sub.rawTextContents?.contains(where: { text in
                    text.lowercased() == newClass.name.description.lowercased()
                }) ?? false
            }
            subsToMatch = matchingSubjects.map({ $0.id })
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if !subsToMatch!.isEmpty {
                    showMatchingSubs = true
                }
            }
        }
    }
}
