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

@available(iOS 16, *)
public struct CUIFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    // TODO: Document
    public init(
        horizontalSpacing: CGFloat = .standardSpacing,
        verticalSpacing: CGFloat = .standardSpacing
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    func rows(
        subviews: Subviews,
        proposal: ProposedViewSize
    ) -> (rows: [[LayoutSubview]], width: CGFloat) {
        var maxWidth: CGFloat = 0

        if let width = proposal.width,
           proposal != .zero,
           proposal != .infinity,
           proposal != .unspecified
        {
            maxWidth = width
        }

        var rows: [[LayoutSubview]] = []

        var actualWidth: CGFloat = 0
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            if currentRowWidth > maxWidth {
                currentRowWidth = 0
            }

            // This will be true for the first run as well.
            if currentRowWidth == 0 {
                rows.append([])
            }

            guard var currentRow = rows.last else {
                // This should never happen
                break
            }

            if currentRowWidth > 0 {
                currentRowWidth += horizontalSpacing
            }

            let subviewWidth = subview.dimensions(in: proposal).width

            currentRowWidth += subviewWidth

            if currentRowWidth > maxWidth {
                rows.append([subview])
                currentRowWidth = subviewWidth
            } else {
                currentRow.append(subview)
                rows[rows.count - 1] = currentRow
            }

            if currentRowWidth > actualWidth {
                actualWidth = currentRowWidth
            }
        }

        return (rows: rows, width: actualWidth)
    }

    // TODO: Handle vertical layouts as well
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let (rows, actualWidth) = rows(subviews: subviews, proposal: proposal)

        var actualHeight: CGFloat = 0

        for row in rows {
            let rowHeight = row.maxHeight(in: proposal)

            if actualHeight > 0 {
                actualHeight += verticalSpacing
            }

            actualHeight += rowHeight
        }

        return CGSize(width: actualWidth, height: actualHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let (rows, _) = rows(subviews: subviews, proposal: proposal)

        var y: CGFloat = 0
        var x: CGFloat = 0

        for row in rows {
            x = 0

            let rowHeight = row.maxHeight(in: proposal)

            if y > 0 {
                y += verticalSpacing
            }

            y += rowHeight / 2

            for subview in row {
                if x > 0 {
                    x += horizontalSpacing
                }

                let subviewWidth = subview.dimensions(in: proposal).width

                x += subviewWidth / 2

                subview.place(
                    at: CGPoint(
                        x: x + bounds.origin.x,
                        y: y + bounds.origin.y
                    ),
                    anchor: .center,
                    proposal: ProposedViewSize(
                        width: subviewWidth,
                        height: rowHeight
                    )
                )

                x += subviewWidth / 2
            }

            y += rowHeight / 2
        }
    }
}

@available(iOS 16, *)
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
    static var previews: some View {
        if #available(iOS 16, *) {
            return CUIFlowLayout {
                ForEach(0 ..< 100, id: \.self) { index in
                    Text("\(index)")
                }
            }
            .padding()
            .background(.gray.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: .cornerRadius))
        } else {
            return EmptyView()
        }
    }
}
