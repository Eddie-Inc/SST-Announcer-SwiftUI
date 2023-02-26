//
//  SubjectVisualiserView.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import SwiftUI
import Chopper
import Updating

struct SubjectVisualiserView<Block: TimeBlock>: View {
    @Updating var subject: Block

    @State var dayHeight: Int
    @State var blockWidth: Int
    @State var font: Font

    var body: some View {
        ZStack {
            background
            foreground.padding(.horizontal, 5)
        }
        .cornerRadius(5)
        .padding(2)
        .overlay(alignment: .bottomLeading) {
            if let teacher = subject.displaySubtext {
                Text(teacher)
                    .font(font)
                    .scaleEffect(.init(0.6))
                    .lineLimit(1)
                    .padding(.leading, -5)
            }
        }
        .frame(width: CGFloat(blockWidth * subject.timeBlocks.count),
               height: CGFloat(dayHeight))
    }

    @ViewBuilder
    var background: some View {
        if let color = subject.displayColor {
            Color.background
            color.opacity(0.5)
        } else if let name = subject.displayName {
            if name.isInvalid {
                Color.red
            } else { // unassigned class
                Color(white: 0.8)
            }
        } else {
            Color.gray
        }
    }

    @ViewBuilder
    var foreground: some View {
        if let name = subject.displayName {
            if name.isInvalid {
                GeometryReader { geom in
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        if geom.size.width > 80 {
                            Text("Unidentifiable!")
                                .font(font)
                                .lineLimit(1)
                        }
                    }
                    .frame(width: geom.size.width, height: geom.size.height)
                }
                .foregroundColor(.background)
            } else { // unassigned class
                Text(name.description)
                    .font(font)
                    .lineLimit(1)
            }
        } else {
            Text("loading").font(font)
        }
    }
}
