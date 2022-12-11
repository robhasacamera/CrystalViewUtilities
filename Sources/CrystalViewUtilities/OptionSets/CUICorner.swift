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

/// A wrapper around `UIRectCorner` that adapts corners to leading and trailing terminology.
public struct CUICorner: OptionSet {
    @Environment(\.layoutDirection) var direction

    public typealias RawValue = Int
    public let rawValue: RawValue

    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public static let none: CUICorner = []
    public static let topLeading = CUICorner(rawValue: 1 << 0)
    public static let topTrailing = CUICorner(rawValue: 1 << 1)
    public static let bottomLeading = CUICorner(rawValue: 1 << 2)
    public static let bottomTrailing = CUICorner(rawValue: 1 << 3)
    public static let allCorners: CUICorner = [topLeading, topTrailing, bottomLeading, bottomTrailing]

    #if os(iOS)
    /// Translates the leading/trailing to left/right depending on the current layout direction.
    public var rectCorner: UIRectCorner {
        let isRTL = direction == .rightToLeft

        var rectCorners: UIRectCorner = []

        if self.contains(.topLeading) {
            rectCorners.insert(isRTL ? .topRight : .topLeft)
        }

        if self.contains(.topTrailing) {
            rectCorners.insert(isRTL ? .topLeft : .topRight)
        }

        if self.contains(.bottomLeading) {
            rectCorners.insert(isRTL ? .bottomRight : .bottomLeft)
        }

        if self.contains(.bottomTrailing) {
            rectCorners.insert(isRTL ? .bottomLeft : .bottomRight)
        }

        return rectCorners
    }
    #endif

    var bezierCorner: BezierCorner {
        let isRTL = direction == .rightToLeft

        var bezierCorners: BezierCorner = []

        if self.contains(.topLeading) {
            bezierCorners.insert(isRTL ? .topRight : .topLeft)
        }

        if self.contains(.topTrailing) {
            bezierCorners.insert(isRTL ? .topLeft : .topRight)
        }

        if self.contains(.bottomLeading) {
            bezierCorners.insert(isRTL ? .bottomRight : .bottomLeft)
        }

        if self.contains(.bottomTrailing) {
            bezierCorners.insert(isRTL ? .bottomLeft : .bottomRight)
        }

        return bezierCorners
    }
}
