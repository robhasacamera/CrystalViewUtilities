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

/// Provides a shape with optional corners to be rounded.
///
/// This was adapted from [Mojtaba Hosseini](https://stackoverflow.com/users/5623035/mojtaba-hosseini)'s [answer on Stack Overflow](https://stackoverflow.com/a/58606176/898984).
public struct CUIRoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: Corner

    /// Initilizes a shape with optional corners to be rounded.
    /// - Parameters:
    ///   - radius: The radius to apply to the corners.
    ///   - corners: The corners to round.
    public init(
        radius: CGFloat = .cornerRadius,
        corners: Corner = .allCorners
    ) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        Path(
            BezierPath(
                rect: rect,
                roundedCorners: corners.bezierCorner,
                cornerRadius: radius
            ).cgPath
        )
    }

    /// A wrapper around `UIRectCorner` that adapts corners to leading and trailing terminology.
    public struct Corner: OptionSet {
        @Environment(\.layoutDirection) var direction

        public typealias RawValue = Int
        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        public static let topLeading = Corner(rawValue: 1 << 0)
        public static let topTrailing = Corner(rawValue: 1 << 1)
        public static let bottomLeading = Corner(rawValue: 1 << 2)
        public static let bottomTrailing = Corner(rawValue: 1 << 3)
        public static let allCorners: Corner = [topLeading, topTrailing, bottomLeading, bottomTrailing]

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
}

struct CUIRoundedCornerShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CUIRoundedCornerShape(radius: 30, corners: .topLeading)
                .foregroundColor(.yellow)

            CUIRoundedCornerShape(radius: 30, corners: .topTrailing)
                .foregroundColor(.yellow)

            CUIRoundedCornerShape(radius: 30, corners: .bottomLeading)
                .foregroundColor(.yellow)

            CUIRoundedCornerShape(radius: 30, corners: .bottomTrailing)
                .foregroundColor(.yellow)

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .topTrailing])
                .foregroundColor(.yellow)

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .bottomTrailing])
                .foregroundColor(.yellow)

            HStack {
                CUIRoundedCornerShape(radius: 30)
                    .foregroundColor(.yellow)
                    .frame(width:60, height: 60)

                CUIRoundedCornerShape(radius: 25)
                    .foregroundColor(.yellow)
                    .frame(width:50, height: 50)

                CUIRoundedCornerShape(radius: 20)
                    .foregroundColor(.yellow)
                    .overlay(alignment: .top, content: {
                        Rectangle().frame(width: 10, height: 20)
                    })
                    .frame(width:50, height: 50)
            }
        }
    }
}

