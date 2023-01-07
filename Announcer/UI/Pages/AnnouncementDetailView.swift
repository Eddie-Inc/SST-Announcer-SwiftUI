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

struct AnnouncementDetailView: View {
    @Binding
    var post: Post

    @Binding
    var posts: [Post]

    @State
    var showEditCategoryView: Bool = false

    @AppStorage("textPresentationMode")
    var textPresentationMode: TextPresentationMode = .rendered

    @AppStorage("fontSize")
    var fontSize: Double = 17

    var body: some View {
        List {
            title

            categories
                .listRowSeparator(.hidden, edges: .top)

            TimeAndReminder(post: post)
                .font(.subheadline)
                .offset(y: -3)
                .listRowSeparator(.hidden, edges: .top)

            bodyText
        }
        .navigationTitle("Post")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.inset)
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

    var links: some View {
        // if it has links
        VStack(alignment: .leading) {
            Text("Links")
                .bold()
            ForEach(["https://www.youtube.com", "https://www.google.com"], id: \.self) { url in
                Text(url)
                    .underline()
                    .foregroundColor(.accentColor)
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

    @State var originalFontSize: Double = 0
    @State var isResizing: Bool = false
    // usually synced with isResizing, but lingers a while after isResizing turns false
    @State var resizePopupOpacity: Float = 0

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
                Log.info("Value: \(value)")
                fontSize = originalFontSize * value
            }
            .onEnded { _ in
                isResizing = false
                withAnimation {
                    resizePopupOpacity = 0
                }
            }
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
