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
        radius: CGFloat = .infinity,
        corners: Corner = .allCorners
    ) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        Path(
            UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners.rectCorner,
                cornerRadii: CGSize(width: radius, height: radius)
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
    }
}

struct CUIRoundedCornerShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CUIRoundedCornerShape(radius: 30, corners: .topLeading)

            CUIRoundedCornerShape(radius: 30, corners: .topTrailing)

            CUIRoundedCornerShape(radius: 30, corners: .bottomLeading)

            CUIRoundedCornerShape(radius: 30, corners: .bottomTrailing)

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .topTrailing])

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .bottomTrailing])

            CUIRoundedCornerShape()
        }
    }
}

