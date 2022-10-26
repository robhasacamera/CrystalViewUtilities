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

    var isHorizontal: Bool {
        axis == .horizontal
    }

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
    ) -> (subviewGroup: [[LayoutSubview]], groupAxisLength: CGFloat) {
        var availableAxisLength: CGFloat = 0

        // For special cases, it'll place one item per row.
        if proposal != .zero,
           proposal != .infinity,
           proposal != .unspecified
        {
            switch axis {
            case .horizontal:
                if let width = proposal.width {
                    availableAxisLength = width
                }
            case .vertical:
                if let height = proposal.height {
                    availableAxisLength = height
                }
            }
        }

        var subviewGroup: [[LayoutSubview]] = []

        var groupAxisLength: CGFloat = 0
        var currentAxisLength: CGFloat = 0

        for subview in subviews {
            if currentAxisLength > availableAxisLength {
                currentAxisLength = 0
            }

            // This will be true for the first run as well.
            if currentAxisLength == 0 {
                subviewGroup.append([])
            }

            guard var currentGroup = subviewGroup.last else {
                // This should never happen
                break
            }

            if currentAxisLength > 0 {
                currentAxisLength += isHorizontal
                    ? horizontalSpacing
                    : verticalSpacing
            }

            let subviewLength = isHorizontal
                ? subview.dimensions(in: proposal).width
                : subview.dimensions(in: proposal).height

            currentAxisLength += subviewLength

            if currentAxisLength > availableAxisLength {
                subviewGroup.append([subview])
                currentAxisLength = subviewLength
            } else {
                currentGroup.append(subview)
                subviewGroup[subviewGroup.count - 1] = currentGroup
            }

            if currentAxisLength > groupAxisLength {
                groupAxisLength = currentAxisLength
            }
        }

        return (subviewGroup: subviewGroup, groupAxisLength: groupAxisLength)
    }

    // FIXME: Have different names besides length and widthOrHeight
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let (subviewGroup, groupAxisLength) = subviewGroup(subviews: subviews, proposal: proposal)

        var crossGroupLength: CGFloat = 0

        for subview in subviewGroup {
            let subviewHeightOrWidth = isHorizontal
                ? subview.maxHeight(in: proposal)
                : subview.maxWidth(in: proposal)

            if crossGroupLength > 0 {
                crossGroupLength += isHorizontal
                    ? verticalSpacing
                    : horizontalSpacing
            }

            crossGroupLength += subviewHeightOrWidth
        }

        let width = isHorizontal
            ? groupAxisLength
            : crossGroupLength
        let height = isHorizontal
            ? crossGroupLength
            : groupAxisLength

        return CGSize(width: width, height: height)
    }

    // This method needs to be refactored desparately after adding alternative axis.
    // majorLength, minorLength
    // length, crossLength
    // axisLength, crossLength
    // lengthAlongAxis, crossLength
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let (subviewGroup, _) = subviewGroup(subviews: subviews, proposal: proposal)

        var axisPosition: CGFloat = 0
        var crossPosition: CGFloat = 0

        for subview in subviewGroup {
            let crossLength = isHorizontal
                ? subview.maxHeight(in: proposal)
                : subview.maxWidth(in: proposal)

            axisPosition = 0

            if crossPosition > 0 {
                crossPosition += isHorizontal
                    ? verticalSpacing
                    : horizontalSpacing
            }

            crossPosition += crossLength / 2

            for subview in subview {
                let axisLength = isHorizontal
                    ? subview.dimensions(in: proposal).width
                    : subview.dimensions(in: proposal).height

                if axisPosition > 0 {
                    axisPosition += isHorizontal
                        ? horizontalSpacing
                        : verticalSpacing
                }

                axisPosition += axisLength / 2

                subview.place(
                    at: CGPoint(
                        x: bounds.origin.x
                            + (
                                isHorizontal
                                    ? axisPosition
                                    : crossPosition
                            ),
                        y: bounds.origin.y
                            + (
                                isHorizontal
                                    ? crossPosition
                                    : axisPosition
                            )
                    ),
                    anchor: .center,
                    proposal: ProposedViewSize(
                        width: isHorizontal
                            ? axisLength
                            : crossLength,
                        height: isHorizontal
                            ? crossLength
                            : axisLength
                    )
                )

                axisPosition += axisLength / 2
            }

            crossPosition += crossLength / 2
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
