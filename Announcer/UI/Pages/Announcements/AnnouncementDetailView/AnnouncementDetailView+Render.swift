//
//  AnnouncementDetailView+Render.swift
//  Announcer
//
//  Created by Kai Quan Tay on 8/1/23.
//

import SwiftUI
import RichText
import PostManager

enum TextPresentationMode: String {
    case rendered, raw, htmlStripped
}

extension AnnouncementDetailView {
    var bodyText: some View {
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
        .padding(.top, textPresentationMode != .rendered ? 10 : 0)
    }
}

struct AnnouncementDetailViewRender_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnnouncementDetailView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     content: "<p>\(placeholderTextLong)<p>",
                     date: .now,
                     blogURL: nil, categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ])),
                                   posts: .constant([]))
        }
    }
}
