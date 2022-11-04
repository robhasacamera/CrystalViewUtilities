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
    var corners: CUICorner

    /// Initilizes a shape with optional corners to be rounded.
    /// - Parameters:
    ///   - radius: The radius to apply to the corners.
    ///   - corners: The corners to round.
    public init(
        radius: CGFloat = .cornerRadius,
        corners: CUICorner = .allCorners
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

