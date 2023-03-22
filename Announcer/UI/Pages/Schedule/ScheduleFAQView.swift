//
//  ScheduleFAQView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 22/3/23.
//

import SwiftUI

struct ScheduleFAQView: View {
    var body: some View {
        DisclosureGroup("How do I edit my schedule?") {
            Text("""
1. Press the info button in the top right
2. To edit subjects, click on "Odd Week" or "Even week"
3. To edit schedule details such as start date, modify the fields directly
4. Save your schedule
""")
        }
        DisclosureGroup("How do I share my schedule?") {
            Text("""
1. Press the share button at the top right
2. Get your friend to scan the QR code
3. Alternatively, share the URL with them
""")
        }
        DisclosureGroup("How do I add a new schedule?") {
            Text("""
1. Press the info button in the top right
2. Click on "Manage Schedules" -> "Add New Schedule"
""")
        }
        DisclosureGroup("Why are there multiple schedules?") {
            Text("""
Announcer supports multiple schedules. You can store your friend's \
schedules, for example. To switch between schedules:
1. Press the info button in the top right
2. Click on "Manage Schedules"
3. Click on the schedule you want to switch to
To delete a schedule, swipe the schedule towards the left.
""")
        }
        DisclosureGroup("How do I see when my classes are?") {
            Text("""
Click on any subject, or go into the Classes page. It will show the \
other instances of that subject, and how long until they happen.
""")
        }
    }
}

struct ScheduleLoadingFAQView: View {
    var body: some View {
        DisclosureGroup("Why isn't my schedule loading?") {
            Text("""
Announcer loads your schedule by detecting the black borders. \
If your schedule is too low resolution, the borders cannot be \
detected accurately. Please use the original schedule image, \
usually from your form room's google classroom
""")
        }
        DisclosureGroup("What is the QR code scanner for?") {
            Text("""
If your friend has their schedule in Announcer, they can press the \
share button (top right). Scan the QR code to load their schedule instantly.
""")
        }
        DisclosureGroup("What are all these red subjects?") {
            Text("""
Announcer uses text recognition to detect the text contents of \
subjects automatically. However, certain subjects (eg. MTL) are \
too complex for Announcer to determine the class, so you will have \
to assign them manually.
To configure a subject manually, click on it and click on "Assign Class"
""")
        }
        DisclosureGroup("How do I add missing subjects?") {
            Text("""
If subjects are missing, go to the day and press the + button. \
Open it and change the time/duration to the correct time/duration.
""")
        }
        DisclosureGroup("How do I assign a subject to a nonexistent class?") {
            Text("""
If you click on "Assign Class" or "Change Class", you can press the + \
button to create a new class. Alternatively, search up the name of the \
class and click on "Create class named [name]".
""")
        }
    }
}

struct ScheduleFAQView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                ScheduleFAQView()
            }
            Section {
                ScheduleLoadingFAQView()
            }
        }
    }
}
