//
//  AnnouncementDetailView+Resize.swift
//  Announcer
//
//  Created by Kai Quan Tay on 8/1/23.
//

import SwiftUI

extension AnnouncementDetailView {
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

struct AnnouncementDetailViewResize_Previews: PreviewProvider {
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
