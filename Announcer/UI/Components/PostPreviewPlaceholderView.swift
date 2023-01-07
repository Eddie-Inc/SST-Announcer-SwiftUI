//
//  PostPreviewPlaceholderView.swift
//  Announcer
//
//  Created by Kai Quan Tay on 7/1/23.
//

import SwiftUI

private var textLengths: [Int] = [21, 10, 29]

struct PostPreviewPlaceholderView: View {
    @State
    var numberOfCategories: Int = .random(in: 0..<3)

    @State
    var numberOfUserCategories: Int = .random(in: 0..<2)

    var body: some View {
        VStack(alignment: .leading) {
            title
            textPreview
            postAndReminder
        }
    }

    var title: some View {
        HStack {
            Text(placeholderTextShort)
                .fontWeight(.semibold)
                .redacted(reason: .placeholder)
                .lineLimit(2)
        }
        .padding(.bottom, 0.5)
    }

    var textPreview: some View {
        ZStack {
            Text(placeholderTextLong)
                .redacted(reason: .placeholder)
                .lineLimit(3)
                .padding(.bottom, 6)
        }
    }

    var postAndReminder: some View {
        HStack {
            Circle()
                .foregroundColor(.gray)
                .opacity(0.5)
                .frame(width: 14, height: 14)
            Text("June 9, 2420")
                .redacted(reason: .placeholder)
                .padding(.trailing, 5)

            ForEach(0..<(numberOfUserCategories + numberOfCategories), id: \.self) { index in
                Text(verbatim: .init(repeating: " ", count: textLengths[index]))
                    .font(.subheadline)
                    .background {
                        Rectangle()
                            .foregroundColor(index < numberOfUserCategories ? .orange : .accentColor)
                            .opacity(0.5)
                            .cornerRadius(5)
                    }
            }
        }
        .font(.footnote)
    }
}

struct PostPreviewPlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PostPreviewPlaceholderView()
            PostPreviewView(post: .constant(
                Post(title: "\(placeholderTextShort) abcdefg \(placeholderTextShort) 1",
                     content: placeholderTextLong,
                     date: .now,
                     pinned: true,
                     read: false,
                     categories: [
                        "short",
                        "secondary 3",
                        "you wanted more?"
                     ])), posts: .constant([]))
        }
    }
}
