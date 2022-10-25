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

// FIXME: Have not found a way to select macOS 12.6 for CI. Will address in future release
#if os(iOS)
/**
 * Creates a layout that flows from one row to the next.
 *
 * Rows are sized to fit as many elements as possible horizontally before wrapping to the next line.
 * Rows will be as tall as their tallest element and elements are centered aligned in the row.
 */
@available(iOS 16, *)
public struct CUIFlowLayout: Layout {
    let axis: Axis
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    // TODO: Add alignment options for row (center, top, bottom)
    // TODO: Add alignment options for layout as a whole (leading, center, trailing), this will probably be much harder
    /// Creates a flow layout using the provided spacing.
    /// - Parameters:
    ///   - horizontalSpacing: Spacing between elements in the row.
    ///   - verticalSpacing: Spacing between rows
    public init(
        axis: Axis = .horizontal,
        horizontalSpacing: CGFloat = .standardSpacing,
        verticalSpacing: CGFloat = .standardSpacing
    ) {
        self.axis = axis
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    func subviewGroup(
        subviews: Subviews,
        proposal: ProposedViewSize
    ) -> (subviewGroup: [[LayoutSubview]], length: CGFloat) {
        var maxLength: CGFloat = 0

        // For special cases, it'll place one item per row.
        if proposal != .zero,
           proposal != .infinity,
           proposal != .unspecified
        {
            switch axis {
            case .horizontal:
                if let width = proposal.width {
                    maxLength = width
                }
            case .vertical:
                if let height = proposal.height {
                    maxLength = height
                }
            }
        }

        var subviewGroup: [[LayoutSubview]] = []

        var length: CGFloat = 0
        var currentLength: CGFloat = 0

        for subview in subviews {
            if currentLength > maxLength {
                currentLength = 0
            }

            // This will be true for the first run as well.
            if currentLength == 0 {
                subviewGroup.append([])
            }

            guard var currentGroup = subviewGroup.last else {
                // This should never happen
                break
            }

            if currentLength > 0 {
                currentLength += axis == .horizontal
                    ? horizontalSpacing
                    : verticalSpacing
            }

            let subviewLength = axis == .horizontal
                ? subview.dimensions(in: proposal).width
                : subview.dimensions(in: proposal).height

            currentLength += subviewLength

            if currentLength > maxLength {
                subviewGroup.append([subview])
                currentLength = subviewLength
            } else {
                currentGroup.append(subview)
                subviewGroup[subviewGroup.count - 1] = currentGroup
            }

            if currentLength > length {
                length = currentLength
            }
        }

        return (subviewGroup: subviewGroup, length: length)
    }

    // FIXME: Have different names besides length and widthOrHeight
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let (subviewGroup, length) = subviewGroup(subviews: subviews, proposal: proposal)

        var heightOrWidth: CGFloat = 0

        for subview in subviewGroup {
            let subviewHeightOrWidth = axis == .horizontal
                ? subview.maxHeight(in: proposal)
                : subview.maxWidth(in: proposal)

            if heightOrWidth > 0 {
                heightOrWidth += axis == .horizontal
                    ? verticalSpacing
                    : horizontalSpacing
            }

            heightOrWidth += subviewHeightOrWidth
        }

        let width: CGFloat
        let height: CGFloat

        switch axis {
        case .horizontal:
            width = length
            height = heightOrWidth
        case .vertical:
            width = heightOrWidth
            height = length
        }

        return CGSize(width: width, height: height)
    }

    // This method needs to be refactored desparately after adding alternative axis.
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let (subviewGroup, _) = subviewGroup(subviews: subviews, proposal: proposal)

        var y: CGFloat = 0
        var x: CGFloat = 0

        for subview in subviewGroup {
            let subviewLength = axis == .horizontal
                ? subview.maxHeight(in: proposal)
                : subview.maxWidth(in: proposal)

            switch axis {
            case .horizontal:
                x = 0

                if y > 0 {
                    y += verticalSpacing
                }

                y += subviewLength / 2
            case .vertical:
                y = 0

                if x > 0 {
                    x += horizontalSpacing
                }

                x += subviewLength / 2
            }

            for subview in subview {
                let subviewWidthOrHeight = axis == .horizontal ?
                    subview.dimensions(in: proposal).width :
                    subview.dimensions(in: proposal).height

                switch axis {
                case .horizontal:
                    if x > 0 {
                        x += horizontalSpacing
                    }

                    x += subviewWidthOrHeight / 2
                case .vertical:
                    if y > 0 {
                        y += verticalSpacing
                    }

                    y += subviewWidthOrHeight / 2
                }

                subview.place(
                    at: CGPoint(
                        x: x + bounds.origin.x,
                        y: y + bounds.origin.y
                    ),
                    anchor: .center,
                    proposal: ProposedViewSize(
                        width: axis == .horizontal
                            ? subviewWidthOrHeight :
                            subviewLength,
                        height: axis == .vertical
                            ? subviewWidthOrHeight
                            : subviewLength
                    )
                )

                switch axis {
                case .horizontal:
                    x += subviewWidthOrHeight / 2
                case .vertical:
                    y += subviewWidthOrHeight / 2
                }
            }

            switch axis {
            case .horizontal:
                y += subviewLength / 2
            case .vertical:
                x += subviewLength / 2
            }
        }
    }
}

@available(iOS 16, macOS 12.6, *)
private extension Array where Element == LayoutSubview {
    func maxHeight(in proposal: ProposedViewSize) -> CGFloat {
        var height: CGFloat = 0

        for subview in self {
            let subviewHeight = subview.dimensions(in: proposal).height

            if subviewHeight > height {
                height = subviewHeight
            }
        }

        return height
    }

    func maxWidth(in proposal: ProposedViewSize) -> CGFloat {
        var width: CGFloat = 0

        for subview in self {
            let subviewWidth = subview.dimensions(in: proposal).width

            if subviewWidth > width {
                width = subviewWidth
            }
        }

        return width
    }
}

struct CUIFlowLayout_Previews: PreviewProvider {
    static func text(for index: Int) -> String {
        if index % 7 == 0 {
            return "wider \(index)"
        } else if index % 9 == 0 {
            return "really\ntall\n\(index)"
        } else if index % 3 == 0 {
            return "taller\n\(index)"
        }

        return "\(index)"
    }

    static var placeholderViews: some View {
        ForEach(0 ..< 50, id: \.self) { index in
            Text(text(for: index))
                .padding(.standardSpacing)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
        }
    }

    static var previews: some View {
        if #available(iOS 16, macOS 12.6, *) {
            return VStack {
                ScrollView {
                    CUIFlowLayout(axis: .horizontal) {
                        placeholderViews
                    }
                    .padding()
                }
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
                .frame(height: 300)

                ScrollView(.horizontal) {
                    CUIFlowLayout(axis: .vertical) {
                        placeholderViews
                    }
                    .padding()
                }
                .frame(height: 300)
                .background(.gray.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
            }
        } else {
            return EmptyView()
        }
    }
}
#endif
