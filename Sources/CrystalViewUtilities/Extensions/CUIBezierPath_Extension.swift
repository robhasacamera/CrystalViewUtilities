//
// CrystalViewUtilities
//
// MIT License
//
// Copyright (c) 2022 Robert Cole
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import SwiftUI

#if os(iOS) || os(tvOS)
import UIKit

public typealias CUIBezierPath = UIBezierPath

#elseif os(macOS)
import AppKit
import Cocoa

public typealias CUIBezierPath = NSBezierPath
#endif

struct BezierCorner: OptionSet {
    public typealias RawValue = Int

    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let topLeft = BezierCorner(rawValue: 1 << 0)
    public static let bottomLeft = BezierCorner(rawValue: 1 << 1)
    public static let topRight = BezierCorner(rawValue: 1 << 2)
    public static let bottomRight = BezierCorner(rawValue: 1 << 3)

    public func flipped() -> BezierCorner {
        var flippedCorners: BezierCorner = []

        if contains(.bottomRight) {
            flippedCorners.insert(.topRight)
        }

        if contains(.topRight) {
            flippedCorners.insert(.bottomRight)
        }

        if contains(.bottomLeft) {
            flippedCorners.insert(.topLeft)
        }

        if contains(.topLeft) {
            flippedCorners.insert(.bottomLeft)
        }

        return flippedCorners
    }
}

// TODO: Make public once I confirm how it works on MacOS without SwiftUI, same for iOS.
/// Adds compatibility bewteen NSBezierPath and UIBezierPath.
///
/// Adapted from https://github.com/janheiermann/BezierPath-Corners
extension CUIBezierPath {
    #if os(iOS) || os(tvOS)
    func curve(to point: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        addCurve(to: point, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }

    func line(to point: CGPoint) {
        addLine(to: point)
    }
    #endif

    convenience init(
        rect: CGRect,
        roundedCorners: BezierCorner,
        cornerRadius: CGFloat,
        cutPositionSet: CUIPositionSet? = nil,
        cutLength: CGFloat? = nil
    ) {
        let maxLength = rect.width > rect.height ? rect.width : rect.height

        let constrainedCornerRadius = min(maxLength.half, cornerRadius)

        self.init()

        let radiusDenom: CGFloat = .pi * 0.75

        let startingPoint: CGPoint = CGPointMake(
            roundedCorners.contains(.topRight) ? cornerRadius : 0,
            rect.minY
        )

        let cutLength = cutLength ?? 0

        move(to: startingPoint)

        let topRightCorner = CGPoint(x: rect.maxX, y: rect.minY)
        let topRightCurveStart = CGPoint(x: rect.maxX - constrainedCornerRadius, y: rect.minY)

        if roundedCorners.contains(.topRight) {
            if let cutPositionSet,
               let alignment = cutPositionSet.hAlignment,
               cutPositionSet.edge == .top
            {
                switch alignment {
                case .center:
                    line(
                        to: CGPoint(
                            x: rect.midX - cutLength.half,
                            y: rect.minY
                        )
                    )

                    move(to: CGPoint(x: rect.midX + cutLength.half, y: rect.minY))

                    line(to: topRightCurveStart)
                case .trailing:
                    line(to: CGPoint(x: rect.maxX - constrainedCornerRadius - cutLength, y: rect.minY))
                    move(to: topRightCurveStart)
                case .leading: fallthrough
                default:
                    move(to: CGPoint(
                        x: startingPoint.x + cutLength,
                        y: startingPoint.y
                    ))

                    line(to: topRightCurveStart)
                }
            } else {
                line(to: topRightCurveStart)
            }

            let controlPoint1 = CGPoint(
                x: topRightCorner.x - constrainedCornerRadius / radiusDenom,
                y: topRightCorner.y
            )
            let controlPoint2 = CGPoint(
                x: topRightCorner.x,
                y: topRightCorner.y + constrainedCornerRadius / radiusDenom
            )
            curve(
                to: CGPoint(x: rect.maxX, y: rect.minY + constrainedCornerRadius),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        } else {
            line(to: topRightCorner)
        }

        let bottomRightCorner = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomRightCurveStart = CGPoint(x: rect.maxX, y: rect.maxY - constrainedCornerRadius)

        if roundedCorners.contains(.bottomRight) {
            if let cutPositionSet,
               let alignment = cutPositionSet.vAlignment,
               cutPositionSet.edge == .trailing
            {
                switch alignment {
                case .center:
                    line(
                        to: CGPoint(
                            x: rect.maxX,
                            y: rect.midY - cutLength.half
                        )
                    )

                    move(to: CGPoint(x: rect.maxX, y: rect.midY + cutLength.half))

                    line(to: bottomRightCurveStart)
                case .bottom:
                    line(to: CGPoint(x: rect.maxX, y: rect.maxY - constrainedCornerRadius - cutLength))
                    move(to: bottomRightCurveStart)
                case .top: fallthrough
                default:
                    move(to: CGPoint(
                        x: rect.maxX,
                        y: cutLength + cornerRadius
                    ))

                    line(to: bottomRightCurveStart)
                }
            } else {
                line(to: bottomRightCurveStart)
            }

            let controlPoint1 = CGPoint(
                x: bottomRightCorner.x,
                y: bottomRightCorner.y - constrainedCornerRadius / radiusDenom
            )
            let controlPoint2 = CGPoint(
                x: bottomRightCorner.x - constrainedCornerRadius / radiusDenom,
                y: bottomRightCorner.y
            )
            curve(
                to: CGPoint(x: rect.maxX - constrainedCornerRadius, y: rect.maxY),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        } else {
            line(to: bottomRightCorner)
        }

        let bottomLeftCorner = CGPoint(x: rect.minX, y: rect.maxY)
        let bottomLeftCurveStart = CGPoint(x: rect.minX + constrainedCornerRadius, y: rect.maxY)

        if roundedCorners.contains(.bottomLeft) {
            if let cutPositionSet,
               let alignment = cutPositionSet.hAlignment,
               cutPositionSet.edge == .bottom
            {
                switch alignment {
                case .center:
                    line(to: CGPoint(
                        x: rect.midX + cutLength.half,
                        y: rect.maxY
                    ))

                    move(to: CGPoint(x: rect.midX - cutLength.half, y: rect.maxY))

                    line(to: bottomLeftCurveStart)
                case .trailing:
                    move(to: CGPoint(
                        x: rect.maxX - constrainedCornerRadius - cutLength,
                        y: rect.maxY
                    ))

                    line(to: bottomLeftCurveStart)
                case .leading: fallthrough
                default:
                    line(to: CGPoint(
                        x: rect.minX + constrainedCornerRadius + cutLength,
                        y: rect.maxY
                    ))

                    move(to: bottomLeftCurveStart)
                }
            } else {
                line(to: bottomLeftCurveStart)
            }

            let controlPoint1 = CGPoint(
                x: bottomLeftCorner.x + constrainedCornerRadius / radiusDenom,
                y: bottomLeftCorner.y
            )
            let controlPoint2 = CGPoint(
                x: bottomLeftCorner.x,
                y: bottomLeftCorner.y - constrainedCornerRadius / radiusDenom
            )
            curve(
                to: CGPoint(x: rect.minX, y: rect.maxY - constrainedCornerRadius),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        } else {
            line(to: bottomLeftCorner)
        }

        let topLeftCorner = CGPoint(x: rect.minX, y: rect.minY)
        let topLeftCurveStart = CGPoint(x: rect.minX, y: rect.minY + constrainedCornerRadius)

        if roundedCorners.contains(.topLeft) {
            if let cutPositionSet,
               let alignment = cutPositionSet.vAlignment,
               cutPositionSet.edge == .leading
            {
                switch alignment {
                case .center:
                    line(
                        to: CGPoint(
                            x: rect.minX,
                            y: rect.midY + cutLength.half
                        )
                    )

                    move(to: CGPoint(x: rect.minX, y: rect.midY - cutLength.half))

                    line(to: topLeftCurveStart)
                case .bottom:
                    move(to: CGPoint(x: rect.minX, y: rect.maxY - constrainedCornerRadius - cutLength))

                    line(to: topLeftCurveStart)
                case .top: fallthrough
                default:
                    line(to: CGPoint(x: rect.minX, y: rect.minY + constrainedCornerRadius + cutLength))

                    move(to: CGPoint(
                        x: rect.minX,
                        y: rect.minY + constrainedCornerRadius
                    ))
                }
            } else {
                line(to: topLeftCurveStart)
            }

            let controlPoint1 = CGPoint(
                x: topLeftCorner.x,
                y: topLeftCorner.y + constrainedCornerRadius / radiusDenom
            )
            let controlPoint2 = CGPoint(
                x: topLeftCorner.x + constrainedCornerRadius / radiusDenom,
                y: topLeftCorner.y
            )
            curve(
                to: CGPoint(x: rect.minX + constrainedCornerRadius, y: rect.minY),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        } else {
            line(to: topLeftCorner)
        }

        if cutPositionSet == nil {
            close()
        }
    }
}

#if os(macOS)

/// Adapted from [rob mayoff](https://stackoverflow.com/users/77567/rob-mayoff)'s [answer on Stack Overflow](https://stackoverflow.com/a/38860552/898984).
public extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path.move(to: points[0])
            case .lineTo: path.addLine(to: points[0])
            case .curveTo: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath: path.closeSubpath()
            @unknown default:
                // TODO: change this to a warning
                print("Found unexpected case: \(type)")
            }
        }
        return path
    }
}

#endif
