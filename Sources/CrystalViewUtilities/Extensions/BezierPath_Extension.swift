//
//  File.swift
//
//
//  Created by Robert Cole on 10/23/22.
//

#if os(iOS) || os(tvOS)
import UIKit

public typealias BezierPath = UIBezierPath

#elseif os(macOS)
import AppKit
import Cocoa

public typealias BezierPath = NSBezierPath
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
extension BezierPath {
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
        cornerRadius: CGFloat
    ) {
        let maxLength = rect.width > rect.height ? rect.width : rect.height

        let constrainedCornerRadius = min(maxLength / 2, cornerRadius)

        self.init()

        let radiusDenom: CGFloat = .pi * 0.75

        let maxX: CGFloat = rect.size.width
        let minX: CGFloat = 0
        let maxY: CGFloat = rect.size.height
        let minY: CGFloat = 0

        let startingPoint: CGPoint = CGPointMake(
            roundedCorners.contains(.topRight) ? cornerRadius : 0,
            minY
        )

        move(to: startingPoint)

        let topRightCorner = CGPoint(x: maxX, y: minY)


        if roundedCorners.contains(.topRight) {
            let controlPoint1 = CGPoint(
                x: topRightCorner.x - constrainedCornerRadius / radiusDenom,
                y: topRightCorner.y
            )
            let controlPoint2 = CGPoint(
                x: topRightCorner.x,
                y: topRightCorner.y + constrainedCornerRadius / radiusDenom
            )

            line(to: CGPoint(x: maxX - constrainedCornerRadius, y: minY))
            curve(
                to: CGPoint(x: maxX, y: minY + constrainedCornerRadius),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        }
        else {
            line(to: topRightCorner)
        }

        let bottomRightCorner = CGPoint(x: maxX, y: maxY)

        if roundedCorners.contains(.bottomRight) {
            let controlPoint1 = CGPoint(
                x: bottomRightCorner.x,
                y: bottomRightCorner.y - constrainedCornerRadius / radiusDenom
            )
            let controlPoint2 = CGPoint(
                x: bottomRightCorner.x - constrainedCornerRadius / radiusDenom,
                y: bottomRightCorner.y
            )

            line(to: CGPoint(x: maxX, y: maxY - constrainedCornerRadius))
            curve(
                to: CGPoint(x: maxX - constrainedCornerRadius, y: maxY),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        }
        else {
            line(to: bottomRightCorner)
        }

        let bottomLeftCorner = CGPoint(x: minX, y: maxY)

        if roundedCorners.contains(.bottomLeft) {
            let controlPoint1 = CGPoint(
                x: bottomLeftCorner.x + constrainedCornerRadius / radiusDenom,
                y: bottomLeftCorner.y
            )
            let controlPoint2 = CGPoint(
                x: bottomLeftCorner.x,
                y: bottomLeftCorner.y - constrainedCornerRadius / radiusDenom
            )

            line(to: CGPoint(x: minX + constrainedCornerRadius, y: maxY))
            curve(
                to: CGPoint(x: minX, y: maxY - constrainedCornerRadius),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        }
        else {
            line(to: bottomLeftCorner)
        }

        let topLeftCorner = CGPoint(x: minX, y: minY)

        if roundedCorners.contains(.topLeft) {
            let controlPoint1 = CGPoint(
                x: topLeftCorner.x,
                y: topLeftCorner.y + constrainedCornerRadius / radiusDenom
            )
            let controlPoint2 = CGPoint(
                x: topLeftCorner.x + constrainedCornerRadius / radiusDenom,
                y: topLeftCorner.y
            )

            line(to: CGPoint(x: minX, y: minY + constrainedCornerRadius))
            curve(
                to: CGPoint(x: minX + constrainedCornerRadius, y: minY),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        }
        else {
            line(to: topLeftCorner)
        }

        close()
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
