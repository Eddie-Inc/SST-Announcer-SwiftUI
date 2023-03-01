//
//  ScheduleSuggestion+Load.swift
//  
//
//  Created by Kai Quan Tay on 1/3/23.
//

import Foundation

extension ScheduleSuggestion {
    /// Loads the text in each subject, sending an onUpdate every
    /// time `self` changes due to a loaded subject.
    public func loadSubjectTexts(onUpdate: @escaping (ScheduleSuggestion) -> Void) {
        guard self.loadProgress == .unloaded else { return } // make sure not already loaded
        var mutableSelf = self
        for index in 0..<mutableSelf.subjects.count {
            mutableSelf.subjects[index].load { newValue in
                mutableSelf.subjects[index] = newValue
                onUpdate(mutableSelf)
            }
        }
    }

    /// Sorts the ``subjects`` into ``SubjectClass``es
    public mutating func loadClasses() {
        guard self.loadProgress == .loaded else { return } // fully load first

        var mutableSelf = self

        for index in 0..<subjects.count {
            let subject = subjects[index]
            if let identifiedClass = mutableSelf.subjectClasses.first(where: { subClass in
                // if name and teacher are identical, assign it to that class
                subClass.name == subject.name && subClass.teacher == subject.teacher
            }) {
                mutableSelf.subjects[index].subjectClass = identifiedClass
                continue
            }

            guard let name = subject.name else { continue }
            switch name {
            case .some(let string):
                // if it is not invalid, create a class for it
                let newClass = SubjectClass(name: name,
                                            teacher: subject.teacher,
                                            color: colorFor(name: string))
                mutableSelf.subjects[index].subjectClass = newClass
                mutableSelf.subjectClasses.append(newClass)
            default: break
            }
        }

        self = mutableSelf
    }

    /// Removes a certain class
    public mutating func deleteClass(subClass: SubjectClass) {
        // mark all the subjects with this class as no-class
        self.subjectClasses.removeAll(where: { $0.id == subClass.id })
        for index in (0..<subjects.count).filter({ subjects[$0].displaySubjectClass?.id == subClass.id }) {
            subjects[index].displaySubjectClass = nil
        }
    }
}
