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

    private var cutPositionSet: CUIPositionSet? = nil
    private var cutLength: CGFloat? = nil

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
                cornerRadius: radius,
                cutPositionSet: cutPositionSet,
                cutLength: cutLength
            )
            .cgPath
        )
    }
}

//
internal extension CUIRoundedCornerShape {
    func cutPath(positionSet: CUIPositionSet?, length: CGFloat?) -> CUIRoundedCornerShape {
        var newSelf = self

        newSelf.cutPositionSet = positionSet
        newSelf.cutLength = length

        return newSelf
    }
}

struct CUIRoundedCornerShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CUIRoundedCornerShape(radius: 30, corners: .topLeading)
                .foregroundColor(.yellow)
                .overlay {
                    Text(".topLeading")
                        .foregroundColor(.black)
                }

            CUIRoundedCornerShape(radius: 30, corners: .topTrailing)
                .foregroundColor(.yellow)
                .overlay {
                    Text(".topTrailing")
                        .foregroundColor(.black)
                }

            CUIRoundedCornerShape(radius: 30, corners: .bottomLeading)
                .foregroundColor(.yellow)
                .overlay {
                    Text(".bottomLeading")
                        .foregroundColor(.black)
                }

            CUIRoundedCornerShape(radius: 30, corners: .bottomTrailing)
                .foregroundColor(.yellow)
                .overlay {
                    Text(".bottomTrailing")
                        .foregroundColor(.black)
                }

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .topTrailing])
                .foregroundColor(.yellow)
                .overlay {
                    Text("[.topLeading, .topTrailing]")
                        .foregroundColor(.black)
                }

            CUIRoundedCornerShape(radius: 30, corners: [.topLeading, .bottomTrailing])
                .foregroundColor(.yellow)
                .overlay {
                    Text("[.topLeading, .bottomTrailing]")
                        .foregroundColor(.black)
                }

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
                        // Used to check the corner radius.
                        Rectangle().frame(width: 10, height: 20)
                            .foregroundColor(.black)
                    })
                    .frame(width:50, height: 50)

                CUIRoundedCornerShape(radius: 20)
                    .stroke(lineWidth: 4)
                    .foregroundColor(.black)
                    .frame(width:70, height: 70)
            }
        }
        .padding()
        .background(.white)
    }
}

