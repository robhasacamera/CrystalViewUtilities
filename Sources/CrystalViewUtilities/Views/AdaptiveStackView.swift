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

// Adapted from https://www.hackingwithswift.com/quick-start/swiftui/how-to-automatically-switch-between-hstack-and-vstack-based-on-size-class
public struct AdaptiveStackView<Content: View>: View {
    @Environment(\.horizontalSizeClass)
    var sizeClass

    var axis: Axis
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    public init(
        axis: @autoclosure () -> Axis,
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis()
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    public init(
        axis: (UserInterfaceSizeClass?) -> Axis,
        horizontalAlignment: HorizontalAlignment = .center,
        verticalAlignment: VerticalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis(nil)
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content

        self.axis = axis(sizeClass)
    }

    public var body: some View {
        if axis == .vertical {
            VStack(
                alignment: horizontalAlignment,
                spacing: spacing,
                content: content
            )
        } else {
            HStack(
                alignment: verticalAlignment,
                spacing: spacing,
                content: content
            )
        }
    }
}

struct AdaptiveStackView_Previews: PreviewProvider {
    struct Preview: View {
        @Namespace
        var animation

        @State var isHorizontal = true

        @State
        var axis: Axis = .horizontal

        var body: some View {
            VStack {
                Spacer()

                AdaptiveStackView(axis: axis) {
                    Text("Placeholder")
                        .matchedGeometryEffect(id: "text", in: animation, properties: .position)

                    Rectangle().foregroundColor(.yellow).frame(width: 100, height: 100)
                        .matchedGeometryEffect(id: "rect", in: animation)
                }
                .animation(.default, value: axis)

                Spacer()

                // This button has to be outside the adaptive stack, otherwise the animation won't happen.
                Button {
                    axis = axis == .horizontal ? .vertical : .horizontal
                } label: {
                    Text("Change Orientation")
                }
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
