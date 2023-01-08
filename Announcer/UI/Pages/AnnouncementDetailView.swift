//
//  AnnouncementDetailView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 3/1/23.
//

import SwiftUI
import RichText

enum TextPresentationMode: String {
    case rendered, raw, htmlStripped
}

let noZeroAndPoint: CharacterSet = .init(["0", "."])

struct AnnouncementDetailView: View {

    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @State
    var showEditCategoryView: Bool = false

    @State
    var showEditReminderDateView: Bool = false

    @AppStorage("textPresentationMode")
    var textPresentationMode: TextPresentationMode = .rendered

    @AppStorage("fontSize")
    var fontSize: Double = 17

    @State
    var safariViewURL: URL?

    @State
    var showSafariView: Bool = false

    var body: some View {
        List {
            title

            categories
                .listRowSeparator(.hidden, edges: .top)

            postAndReminder
                .listRowSeparator(.hidden, edges: .top)

            if !post.getLinks().isEmpty {
                links
            }

            bodyText
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
        .overlay(alignment: .bottom) {
            sizeView
                .opacity(resizePopupOpacity)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    post.pinned.toggle()
                } label: {
                    Image(systemName: post.pinned ? "pin.fill" : "pin")
                }
            }
        }
        .sheet(isPresented: $showEditCategoryView) {
            if #available(iOS 16.0, *) {
                addNewCategory
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                addNewCategory
            }
        }
        .sheet(isPresented: $showEditReminderDateView) {
            if #available(iOS 16.0, *) {
                editReminderDate
                    .presentationDetents(Set([.large, .medium]))
            } else {
                // Fallback on earlier versions
                editReminderDate
            }
        }
        .sheet(isPresented: $showSafariView) {
            if let safariViewURL {
                SafariView(url: safariViewURL)
            } else {
                Text("URL not found")
            }
        }
    }

    var title: some View {
        // title
        HStack {
            Text(post.title)
                .bold()
                .multilineTextAlignment(.leading)
        }
        .font(.title2)
        .padding(.bottom, -5)
    }

    var categories: some View {
        // categories
        HStack {
            CategoryScrollView(post: $post)
                .font(.subheadline)
            Button {
                // add category
                showEditCategoryView.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .opacity(0.6)
            }
        }
    }

    var postAndReminder: some View {
        HStack {
            TimeAndReminder(post: $post)
                .font(.subheadline)
            Spacer()
            Button {
                showEditReminderDateView.toggle()
            } label: {
                if post.reminderDate == nil {
                    Image(systemName: "calendar.badge.plus")
                } else {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            .opacity(0.6)
        }
    }

    var links: some View {
        VStack(alignment: .leading) {
            ForEach(post.getLinks(), id: \.absoluteString) { url in
                Button(url.description) {
                    safariViewURL = url
                    showSafariView = true
                }
            }
        }
    }

    var bodyText: some View {
        // body text
        VStack {
            switch textPresentationMode {
            case .rendered:
                RichText(html: post.content.stripHtmlFont())
                    .placeholder {
                        Text("loading")
                    }
                    .customCSS("* { font-size: \(fontSize)px; }")
                    .padding(-10)
            case .raw:
                Text(post.content)
                    .font(.system(size: CGFloat(fontSize)))
            case .htmlStripped:
                Text(post.content.stripHTML().trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size: CGFloat(fontSize)))
            }
        }
        .gesture(sizeIncreaseGesture)
        .contextMenu {
            Menu("Change Text Rendering Method") {
                Button { textPresentationMode = .rendered } label: {
                    HStack {
                        if textPresentationMode == .rendered {
                            Image(systemName: "checkmark")
                        }
                        Text("Rendered (Recomended)")
                    }
                }
                Button { textPresentationMode = .raw } label: {
                    HStack {
                        if textPresentationMode == .raw {
                            Image(systemName: "checkmark")
                        }
                        Text("Raw")
                    }
                }
                Button { textPresentationMode = .htmlStripped } label: {
                    HStack {
                        if textPresentationMode == .htmlStripped {
                            Image(systemName: "checkmark")
                        }
                        Text("HTML Stripped")
                    }
                }
            }
            Button("Open in Safari") {}
        }
        .overlay(alignment: .topTrailing) {
            Button {
                // open in safari
                safariViewURL = post.getBlogURL()
                showSafariView = true
            } label: {
                Image(systemName: "arrow.up.forward.circle")
                    .opacity(0.6)
                    .offset(x: 6, y: 3)
            }
        }
        .padding(.top, textPresentationMode != .rendered ? 10 : 0)
    }

    var addNewCategory: some View {
        NavigationView {
            EditCategoriesView(post: $post,
                               posts: $posts,
                               showEditCategoryView: $showEditCategoryView)
        }
    }

    var editReminderDate: some View {
        NavigationView {
            EditReminderDateView(post: $post,
                                 showEditReminderDateView: $showEditReminderDateView)
        }
    }

    @State var originalFontSize: Double = 0
    @State var isResizing: Bool = false
    // usually synced with isResizing, but lingers a while after isResizing turns false
    @State var resizePopupOpacity: Double = 0

    var sizeIncreaseGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                if !isResizing {
                    // if it is the start of the gesture, set the original font size
                    originalFontSize = fontSize
                    isResizing = true
                    resizePopupOpacity = 1
                    return
                }

                // if not, then update the font size according to the translation
                fontSize = originalFontSize * value
            }
            .onEnded { _ in
                isResizing = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    guard !isResizing else { return } // make sure we're not resizing
                    withAnimation {
                        resizePopupOpacity = 0
                    }
                }
            }
    }

    var sizeView: some View {
        HStack {
            Text(cleanFontSize())
                .font(.subheadline)

            Button {
                withAnimation {
                    fontSize = UIFont.labelFontSize
                }
            } label: {
                Image(systemName: "equal.circle")
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 5)
        .background {
            Rectangle()
                .foregroundColor(.init(UIColor.systemGroupedBackground))
                .cornerRadius(5)
        }
        .padding(.bottom, 10)
    }

    func cleanFontSize() -> String {
        let rounded = ((fontSize * 10).rounded())/10
        return "\(rounded)".trimmingCharacters(in: noZeroAndPoint)
    }
}

struct AnnouncementDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     content: "<p>\(placeholderTextLong)<p>",
                     date: .now,
                     pinned: true,
                     read: false,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ],
                     userCategories: [
                        .init("placeholder")
                     ])), posts: .constant([]))
        }
    }
}
