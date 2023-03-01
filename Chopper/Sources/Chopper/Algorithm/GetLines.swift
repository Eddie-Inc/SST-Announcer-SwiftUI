//
//  GetLines.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import SwiftUI

extension UIImage {
    // get the vertical lines
    // scan height is the height to scan, usually top + thickness*2 for the schedule thing at the top
    func getLinesHorizontal(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                            measurements: BoundsData,
                            width: Int,
                            scanHeight: Int,
                            startWidth: Int = -1,
                            endWidth: Int = -1,
                            minSpacing: Int = 5,
                            detectBlack: Bool = true) -> [Int] {
        var lines: [Int] = []
        let startingWidth = startWidth == -1 ? (
            measurements.left + measurements.thick*2
        ) : startWidth // left + thickness*2
        let endingWidth = endWidth == -1 ? measurements.right : endWidth // right

        // go until endingWidth

        var lastWasBlack = false
        for column in startingWidth..<endingWidth {
            let offset = (scanHeight * width) + column
            let requirement = detectBlack ? pixelBuffer[offset].isBlackish : !pixelBuffer[offset].isWhitish
            if requirement && !lastWasBlack {
                pixelBuffer[offset] = .red
                lines.append(column)
                lastWasBlack = true
            } else {
                pixelBuffer[offset] = .blue
                lastWasBlack = false
            }
        }

        if lines.isEmpty { return [] }

        // if any of the lines are suspiciously close to each other (5px or less by default), only keep the first one
        for index in (1..<lines.count).reversed() where lines[index] - lines[index-1] < minSpacing {
            lines.remove(at: index-1)
        }

        // fill them in
        for line in lines {
            for additionalHeight in 0..<30 {
                pixelBuffer[scanHeight*width + additionalHeight*width + line] = .red
            }
        }

        return lines
    }

    // get the vertical lines
    // scan width is the column at which to scan. Usually the first schedule line + 1 for days
    func getLinesVertical(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                          measurements: BoundsData,
                          width: Int,
                          scanWidth: Int,
                          startHeight: Int = -1,
                          endHeight: Int = -1) -> [Int] {
        var lines: [Int] = []

        let defaultStart = measurements.top + measurements.thick
        let startingHeight: Int = startHeight == -1 ? defaultStart : startHeight
        let defaultEnd = measurements.bottom - measurements.thick
        let endingHeight: Int = endHeight == -1 ? defaultEnd : endHeight

        // iterate over lines
        var lastWasBlack = false
        for row in startingHeight..<endingHeight {
            let offset = (row * width) + scanWidth
            if pixelBuffer[offset].isBlackish {
                lastWasBlack = true
                pixelBuffer[offset] = .blue
            } else {
                if lastWasBlack {
                    lines.append(row)
                }
                lastWasBlack = false
                pixelBuffer[offset] = .green
            }
        }

        // fill them in
        for line in lines {
            for additionalWidth in 0..<30 {
                pixelBuffer[line*width + additionalWidth + scanWidth] = .red
            }
        }

        return lines
    }

    func getArea(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                 scanArea: CGRect,
                 width: Int,
                 target: RGBA32 = .black,
                 frequency: Int = 2) -> [CGPoint] {
        // iterate over every pixel in the scan area, return those which match the target
        var points: [CGPoint] = []
        for row in stride(from: Int(scanArea.minY), to: Int(scanArea.maxY), by: frequency) {
            let rowOffset = (row * width)
            for col in stride(from: Int(scanArea.minX), to: Int(scanArea.maxX), by: frequency) {
                let offset = rowOffset + col
                if pixelBuffer[offset].roughlyMatches(color: target) {
                    pixelBuffer[offset] = .cyan
                    points.append(.init(x: col, y: row))
                }
            }
        }

        return points
    }
}
