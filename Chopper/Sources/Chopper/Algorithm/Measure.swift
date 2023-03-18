//
//  UIImage+Measure.swift
//  scheduleChopper
//
//  Created by Kai Quan Tay on 21/2/23.
//

import SwiftUI

extension UIImage {
    func measure(pixelBuffer: UnsafeMutablePointer<RGBA32>, height: Int, width: Int) throws -> BoundsData {
        let verticalScanHeight = height/2

        // left side
        let (firstColumn, firstColumnEnd) = measureSide(left: true,
                                                        pixelBuffer: pixelBuffer,
                                                        width: width,
                                                        verticalScanHeight: verticalScanHeight)

        // right side
        let (lastColumn, lastColumnEnd) = measureSide(left: false,
                                                      pixelBuffer: pixelBuffer,
                                                      width: width,
                                                      verticalScanHeight: verticalScanHeight)

        guard firstColumn != -1 &&
                lastColumn != -1 &&
                firstColumnEnd != -1 &&
                lastColumnEnd != -1
        else {
            print("Left/right not valid")
            throw ChopError.borderNotValid
        }

        // thickness
        guard firstColumnEnd-firstColumn == lastColumn-lastColumnEnd else {
            print("Thickness not valid")
            throw ChopError.borderNotValid
        }
        let thickness = firstColumnEnd-firstColumn

        // MARK: Top
        // find the top for the left side
        print("Finding top")
        let top = try measureVertical(top: true,
                                      pixelBuffer: pixelBuffer,
                                      firstColumn: firstColumn,
                                      lastColumn: lastColumn,
                                      width: width,
                                      verticalScanHeight: verticalScanHeight)
        print("Finding bottom")

        // MARK: Bottom
        let bottom = try measureVertical(top: false,
                                         pixelBuffer: pixelBuffer,
                                         firstColumn: firstColumn,
                                         lastColumn: lastColumn,
                                         width: width,
                                         verticalScanHeight: verticalScanHeight)
        print("Measure finishing")

        // MARK: draw top and bottom lines
        for column in firstColumn..<lastColumn {
            let topOffset = (top * width) + column
            let bottomOffset = (bottom * width) + column

            pixelBuffer[topOffset] = .magenta
            pixelBuffer[bottomOffset] = .magenta
        }

        return .init(top: top, left: firstColumn, right: lastColumn, bottom: bottom, thick: thickness)
    }

    func measureSide(left: Bool,
                     pixelBuffer: UnsafeMutablePointer<RGBA32>,
                     width: Int,
                     verticalScanHeight: Int) -> (Int, Int) {
        let condition: (Int, Int) -> Int = left ? { $1 } : { $0 - $1 }
        var foundBlack = false
        var columnStart = -1
        var columnEnd = -1
        for column in 0..<Int(width) {
            let offset = (verticalScanHeight * width) + condition(width, column)
            if pixelBuffer[offset].isWhitish {
                if foundBlack {
                    columnEnd = condition(width, column)
                    break
                } else {
                    pixelBuffer[offset] = .red
                }
            } else {
                foundBlack = true
                pixelBuffer[offset] = .cyan
                if columnStart == -1 {
                    columnStart = condition(width, column)
                }
            }
        }
        return (columnStart, columnEnd)
    }

    // swiftlint:disable:next function_parameter_count
    func measureVertical(top: Bool,
                         pixelBuffer: UnsafeMutablePointer<RGBA32>,
                         firstColumn: Int,
                         lastColumn: Int,
                         width: Int,
                         verticalScanHeight: Int) throws -> Int {
        let multiplier = top ? -1 : 1

        // find the bound for the left side
        var leftBound = -1
        for row in 0..<verticalScanHeight {
            let offset = ((verticalScanHeight+row*multiplier) * width) + firstColumn
            if pixelBuffer[offset].isWhitish {
                leftBound = verticalScanHeight+row*multiplier
                break
            } else {
                pixelBuffer[offset] = .magenta
            }
        }
        // find the bound for the right side (should be equal to the left)
        var rightBound = -1
        for row in 0..<verticalScanHeight {
            let offset = ((verticalScanHeight+row*multiplier) * width) + lastColumn
            if pixelBuffer[offset].isWhitish {
                rightBound = verticalScanHeight+row*multiplier
                break
            } else {
                pixelBuffer[offset] = .magenta
            }
        }
        guard leftBound == rightBound else {
            print("Left and right bounds do not match. Left: \(leftBound), right: \(rightBound)")
            throw ChopError.borderNotValid
        }
        return leftBound
    }
}
