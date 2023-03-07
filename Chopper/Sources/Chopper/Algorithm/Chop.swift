//
//  ScheduleChopper.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 14/2/23.
//

import Foundation
import SwiftUI

extension UIImage {
    struct BoundsData {
        var top: Int
        var left: Int
        var right: Int
        var bottom: Int
        var thick: Int
    }

    /// Chops an image containing a schedule into subjects. Returns nil if unsuccessful.
    /// The first element in the array is an annotated version of the original image, the rest are cropped
    /// subjects containing the image and some data about the time it represents.
    public func chop() throws -> [SubjectSuggestion]? {
        guard let inputCGImage = self.cgImage else {
            return nil
        }

        // setup
        let width = inputCGImage.width
        let height = inputCGImage.height
        guard let (context, pixelBuffer) = getBuffer(cgImage: inputCGImage) else {
            return nil
        }

        // get the measurements of the schedule
        let measurements = try measure(pixelBuffer: pixelBuffer,
                                       height: height,
                                       width: width)

        // get the width of each "block" of 20 minutes
        let (scheduleLines, blockWidth) = getBlocks(pixelBuffer: pixelBuffer,
                                                    measurements: measurements,
                                                    width: width)

        // get the height of each day
        let (dayLines, dayHeight) = try getDays(pixelBuffer: pixelBuffer,
                                                measurements: measurements,
                                                scheduleLines: scheduleLines,
                                                width: width)

        // get the subjects for each day
        let frameOfSubjects = getSubjectFrames(pixelBuffer: pixelBuffer,
                                               measurements: measurements,
                                               dayLines: dayLines,
                                               blockWidth: blockWidth,
                                               dayHeight: dayHeight,
                                               width: width)

        let outputCGImage = context.makeImage()!
        let outputImage = UIImage(cgImage: outputCGImage, scale: self.scale, orientation: self.imageOrientation)

        // crop all the subjects as well. Output image is the first item in the array.
        var imageArray: [SubjectSuggestion] = [.init(image: outputImage,
                                                     timeRange: .startTime ..<
                                                                .startTime.addingBlocks(blocks: scheduleLines.count),
                                                     rawDay: -1)]
        imageArray.append(contentsOf: cropSubjectFrames(cgImage: inputCGImage,
                                                        frameOfSubjects: frameOfSubjects,
                                                        scheduleLines: scheduleLines,
                                                        dayLines: dayLines))

        return imageArray
    }

    func getBuffer(cgImage: CGImage) -> (CGContext, UnsafeMutablePointer<RGBA32>)? {
        // setup
        let colorSpace       = CGColorSpaceCreateDeviceRGB()
        let width            = cgImage.width
        let height           = cgImage.height
        let bytesPerPixel    = 4
        let bitsPerComponent = 8
        let bytesPerRow      = bytesPerPixel * width
        let bitmapInfo       = RGBA32.bitmapInfo

        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else {
            return nil
        }

        return (context, buffer.bindMemory(to: RGBA32.self, capacity: width * height))
    }

    // swiftlint:disable:next function_parameter_count
    func getSubjectFrames(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                          measurements: BoundsData,
                          dayLines: [Int],
                          blockWidth: Int,
                          dayHeight: Int,
                          width: Int) -> [CGRect] {
        // get the subjects for each day
        var frameOfSubjects: [CGRect] = []
        for dayLine in dayLines {
            let linesForDay = getLinesHorizontal(pixelBuffer: pixelBuffer,
                                                 measurements: measurements,
                                                 width: width,
                                                 scanHeight: dayLine+1,
                                                 startWidth: blockWidth*3)

            for index in 0..<linesForDay.count-1 {
                let leftBound = linesForDay[index]
                let rightBound = linesForDay[index+1]
                frameOfSubjects.append(.init(x: leftBound,
                                             y: dayLine-1,
                                             width: rightBound-leftBound,
                                             height: dayHeight))
            }
        }

        // remove any "blank" subjects by firing a beam into it and detecting if anything gets triggered
        frameOfSubjects = frameOfSubjects.filter { rect in
            // remove small ones
            guard rect.width > CGFloat(blockWidth * 2 / 3) else { return false }

            let padding: Int = 10
            return !getArea(pixelBuffer: pixelBuffer,
                            scanArea: .init(x: Int(rect.minX)+padding,
                                            y: Int(rect.minY)+padding,
                                            width: Int(rect.width)-padding*2,
                                            height: Int(rect.height)-padding*2),
                            width: width,
                            frequency: 4).isEmpty
        }

        return frameOfSubjects
    }

    func cropSubjectFrames(cgImage: CGImage,
                           frameOfSubjects: [CGRect],
                           scheduleLines: [Int],
                           dayLines: [Int]) -> [SubjectSuggestion] {
        var imageArray: [SubjectSuggestion] = []
        frameOfSubjects.forEach { rect in
            let adjusted: CGRect = .init(x: rect.minX, y: rect.minY, width: rect.width+1, height: rect.height)
            guard let crop = cgImage.cropping(to: adjusted) else { return }
            let image = UIImage(cgImage: crop)

            // estimate which block's start the start of this subject is closest to
            let start = scheduleLines.firstIndex(of: closestValue(in: scheduleLines, to: Int(rect.minX))) ?? -1

            // estimate which block's end the end of this subjet is closest to
            let end = scheduleLines.firstIndex(of: closestValue(in: scheduleLines, to: Int(rect.maxX))) ?? -1

            // estimate which day's start is closest to this subject's minY
            let day = dayLines.firstIndex(of: closestValue(in: dayLines, to: Int(rect.minY))) ?? -1

            let lowerBound = TimePoint.startTime.addingBlocks(blocks: start)
            let upperBound = TimePoint.startTime.addingBlocks(blocks: end)

            imageArray.append(.init(image: image,
                                    timeRange: lowerBound ..< upperBound,
                                    rawDay: day))
        }

        return imageArray
    }

    func getBlocks(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                   measurements: BoundsData,
                   width: Int) -> ([Int], Int) {
        let scheduleLines = getLinesHorizontal(pixelBuffer: pixelBuffer,
                                               measurements: measurements,
                                               width: width,
                                               scanHeight: measurements.top + measurements.thick*2)
        var blockDifferences: [Int] = []
        for index in 0..<scheduleLines.count-1 {
            let diff = scheduleLines[index+1]-scheduleLines[index]
            if !blockDifferences.contains(diff) { blockDifferences.append(diff) }
        }
        // take the average of the differences and round them down for occasional math use
        let blockWidth = Int(blockDifferences.reduce(0, { $0 + $1 }) / blockDifferences.count)

        return (scheduleLines, blockWidth)
    }

    func getDays(pixelBuffer: UnsafeMutablePointer<RGBA32>,
                 measurements: BoundsData,
                 scheduleLines: [Int],
                 width: Int) throws -> ([Int], Int) {
        let dayLines = getLinesVertical(pixelBuffer: pixelBuffer,
                                        measurements: measurements,
                                        width: width,
                                        scanWidth: scheduleLines.first!-5)
        guard dayLines.count == 10 else { throw ChopError.wrongNumberOfDays }
        var dayDifferences: [Int] = []
        for index in 0..<dayLines.count-1 {
            let diff = dayLines[index+1]-dayLines[index]
            if !dayDifferences.contains(diff) { dayDifferences.append(diff) }
        }
        // take the average of the differences and round them down for occasional math use
        let dayHeight = Int(dayDifferences.reduce(0, { $0 + $1 }) / dayDifferences.count)

        return (dayLines, dayHeight)
    }

    enum ChopError: Error {
        case wrongNumberOfDays
        case borderNotValid
    }
}

private func closestValue(in arr: [Int], to number: Int) -> Int {
    var nearest = arr[0] // initialize nearest to first element of array

    for index in 0..<arr.count where abs(arr[index] - number) < abs(nearest - number) {
        nearest = arr[index]
    }

    return nearest
}
