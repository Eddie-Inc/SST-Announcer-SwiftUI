//
//  ShareSheet.swift
//  Announcer
//
//  Created by Kai Quan Tay on 11/1/23.
//

import SwiftUI

struct ActivityView<Content>: UIViewControllerRepresentable {
    let content: Content

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [content], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {
    }
}
