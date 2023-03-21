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

    @State var showCodeScanner: Bool = false

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

                Button("Show code scanner") {
                    showCodeScanner = true
                }
                .sheet(isPresented: $showCodeScanner) {
                    CodeScannerView(codeTypes: [.qr]) { result in
                        defer { showCodeScanner = false }

                        switch result {
                        case .success(let result):
                            decodeURL(urlString: result.string)
                        case .failure(let failure):
                            print("Failure: \(failure.localizedDescription)")
                        }
                    }
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

    func decodeURL(urlString: String) {
        guard let url = URL(string: urlString),
              let scheme = url.scheme,
              scheme.localizedCaseInsensitiveCompare("announcer") == .orderedSame
        else { return }

        var parameters: [String: String] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }

        guard url.host == "schedule", let source = parameters["source"] else { return }

        guard let schedule = Schedule.decode(from: source) else { return }

        // TODO: show confirmation thing
        let manager = ScheduleManager.default
        manager.addSchedule(schedule: schedule)
        showProvideSuggestion = false
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
    static let listRowBackground: Color = .init(uiColor: .secondarySystemBackground)
}
