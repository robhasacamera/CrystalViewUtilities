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

/// A view that visually groups the child view provided to it.
///
/// This view adds a border around the provided view to visually group the views belonging to the view.
/// A label can be added and positioned using ``CUIPositionSet``. The provided views are clipped
/// to remain within the border.
///
public struct CUITitledGroup<Label: View, Content: View>: View {
    /// Options for sizing ``CUITitledGroup``
    public enum SizingOption {
        /// Alignment based sizing will constrain the size of the view to the midline of the stroke.
        ///
        /// When using alignment based sizing, the stroke and label will be draw partially outside the frame of the view.
        /// This is useful when aligning multiple ``CUITitledGroup`` views that have different stroke sizes and/or label positions.
        case alignment
        /// Bounds based sizing will expand the size of the view to contain the full label and stroke.
        ///
        /// When using bounds based sizing, the stroke and label will be draw fully inside the frame of the view.
        /// This is useful when the ``CUITitledGroup`` is used in a layout with tight layout constraints.
        /// This allows the view to the placed without worry that the stroke or label will be drawn over or under another view.
        case bounds
    }

    @State
    var id = UUID()

    var positionSet: CUIPositionSet
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var label: Label
    var sizing: SizingOption
    var content: Content

    @State
    var labelSize: CGSize = .zero

    /// Creates a titled group for the view provided.
    /// - Parameters:
    ///   - positionSet: The position for the group's label.
    ///   - lineWidth: The width of the border around the view.
    ///   - cornerRadius: The radius for the corners of the border.
    ///   - sizing: Controls the constrained size of the view.
    ///   - label: The label that will be inserted along the border of the view..
    ///   - content: The content to diplay within the titled group.
    public init(
        positionSet: CUIPositionSet = .topEdge(.leading),
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        sizing: SizingOption = .alignment,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.positionSet = positionSet
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.sizing = sizing
        self.label = label()
        self.content = content()
    }

    var labelView: some View {
        CUIChildSizeReader(size: $labelSize, id: id) {
            label
                .padding(
                    layoutInfo.labelToStrokePaddingEdge,
                    .standardSpacing.half
                )
                .position(layoutInfo.position)
        }
    }

    private struct LayoutInfo {
        let alignment: Alignment
        let position: CGPoint
        let labelToStrokePaddingEdge: Edge.Set
        let labelToOuterPaddingEdge: Edge.Set
        let labelToOuterPaddingLength: CGFloat
        // TODO: Not the cleanest implementation
        let strokeCutLength: CGFloat?
    }

    private func horizontalLayoutInfo(_ hEdge: CUIHorizontalEdge, _ hAlignment: HorizontalAlignment) -> CUITitledGroup<Label, Content>.LayoutInfo {
        // FIXME: This is still a weird fix, it looks like label height isn't taken into account for the overlay
        let y: CGFloat = hEdge == .top ? 0 : labelSize.height

        let alignment: Alignment
        let position: CGPoint

        switch hAlignment {
        case .center:
            alignment = hEdge == .top ? .top : .bottom
            position = CGPoint(
                x: labelSize.width.half,
                y: y
            )
        case .trailing:
            alignment = hEdge == .top ? .topTrailing : .bottomTrailing
            position = CGPoint(
                x: labelSize.width.half - cornerRadius,
                y: y
            )
        case .leading: fallthrough
        default:
            alignment = hEdge == .top ? .topLeading : .bottomLeading
            position = CGPoint(
                x: labelSize.width.half + cornerRadius,
                y: y
            )
        }

        return LayoutInfo(
            alignment: alignment,
            position: position,
            labelToStrokePaddingEdge: .horizontal,
            labelToOuterPaddingEdge: hEdge == .top ? .top : .bottom,
            labelToOuterPaddingLength: (labelSize.height - lineWidth).half,
            strokeCutLength: label is EmptyView ? 0 : labelSize.width
        )
    }

    private func verticalLayoutInfo(_ vEdge: CUIVerticalEdge, _ vAlignment: VerticalAlignment) -> CUITitledGroup<Label, Content>.LayoutInfo {
        // FIXME: This is still a weird fix, it looks like label width isn't taken into account for the overlay
        let x: CGFloat = vEdge == .leading ? 0 : labelSize.width

        let alignment: Alignment
        let position: CGPoint

        switch vAlignment {
        case .center:
            alignment = vEdge == .leading ? .leading : .trailing
            position = CGPoint(
                x: x,
                y: labelSize.height.half
            )
        case .bottom:
            alignment = vEdge == .leading ? .bottomLeading : .bottomTrailing
            position = CGPoint(
                x: x,
                y: labelSize.height.half - cornerRadius
            )
        case .top: fallthrough
        default:
            alignment = vEdge == .leading ? .topLeading : .topTrailing
            position = CGPoint(
                x: x,
                y: labelSize.height.half + cornerRadius
            )
        }

        return LayoutInfo(
            alignment: alignment,
            position: position,
            labelToStrokePaddingEdge: .vertical,
            labelToOuterPaddingEdge: vEdge == .leading ? .leading : .trailing,
            labelToOuterPaddingLength: (labelSize.width - lineWidth).half,
            strokeCutLength: label is EmptyView ? 0 : labelSize.height
        )
    }

    private var layoutInfo: LayoutInfo {
        switch positionSet {
        case .topEdge(let alignment):
            return horizontalLayoutInfo(.top, alignment)
        case .bottomEdge(let alignment):
            return horizontalLayoutInfo(.bottom, alignment)
        case .leadingEdge(let alignment):
            return verticalLayoutInfo(.leading, alignment)
        case .trailingEdge(let alignment):
            return verticalLayoutInfo(.trailing, alignment)
        }
    }

    public var body: some View {
        content
            .padding(lineWidth.half)
            // Note: 0 is specified instead of nil as it was cauing the
            // minHeight to be assigned as the height otherwise.
            .frame(
                minWidth: positionSet.axis == .horizontal
                    ? labelSize.width + cornerRadius * 2
                    : 0,
                minHeight: layoutInfo.labelToStrokePaddingEdge == .vertical
                    ? labelSize.height + cornerRadius * 2
                    : 0
            )
            .clipShape(CUIRoundedCornerShape(radius: cornerRadius))
            .overlay(
                CUIRoundedCornerShape(radius: cornerRadius)
                    .cutPath(
                        positionSet: positionSet,
                        length: layoutInfo.strokeCutLength
                    )
                    .stroke(lineWidth: lineWidth)
                    .flipsForRightToLeftLayoutDirection(true)
            )
            .overlay(alignment: layoutInfo.alignment) {
                labelView
                    .fixedSize()
            }
            .padding(
                sizing == .alignment ? .all : layoutInfo.labelToOuterPaddingEdge,
                sizing == .alignment ? 0 : layoutInfo.labelToOuterPaddingLength
            )
            .padding(sizing == .alignment ? 0 : lineWidth.half)
    }
}

fileprivate enum CUIHorizontalEdge {
    case top
    case bottom
}

fileprivate enum CUIVerticalEdge {
    case leading
    case trailing
}

public extension CUITitledGroup where Label == CUITitledGroupTextLabel {
    /// Creates a titled group for the view provided using the provided text for the label.
    ///
    /// When the label is positioned on the leading or trailing edge of the view, the label will automatically be rotated 90 degrees
    /// - Parameters:
    ///   - positionSet: The position for the group's label.
    ///   - title: The text to display in the label
    ///   - lineWidth: The width of the border around the view.
    ///   - cornerRadius: The radius for the corners of the border.
    ///   - sizing: Controls the constrained size of the view.
    ///   - content: The content to diplay within the titled group.
    init(
        positionSet: CUIPositionSet = .topEdge(.leading),
        title: String,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        sizing: SizingOption = .bounds,
        @ViewBuilder content: () -> Content
    ) {
        let isRotated = positionSet.isVertical

        self.init(
            positionSet: positionSet,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            sizing: sizing
        ) {
            CUITitledGroupTextLabel(text: title, isRotated: isRotated)
        } content: {
            content()
        }
    }
}

public extension CUITitledGroup where Label == EmptyView {
    /// Creates a titled group for the view provided that doesn't have a label.
    /// - Parameters:
    ///   - positionSet: The position for the group's label.
    ///   - lineWidth: The width of the border around the view.
    ///   - cornerRadius: The radius for the corners of the border.
    ///   - sizing: Controls the constrained size of the view.
    ///   - content: The content to diplay within the titled group.
    init(
        positionSet: CUIPositionSet = .topEdge(.leading),
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        sizing: SizingOption = .alignment,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            positionSet: positionSet,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius,
            sizing: sizing
        ) {
            EmptyView()
        } content: {
            content()
        }
    }
}

struct CUITitledGroup_Previews: PreviewProvider {
    static var testContent: some View {
        Rectangle()
            .foregroundColor(.blue.veryTransperent)
            .frame(width: 70, height: 70)
    }

    static var previews: some View {
        VStack {
            HStack {
                VStack {
                    CUITitledGroup(title: "Title") {
                        Text("top edge, leading LTR")
                            .padding(.standardSpacing)
                    }

                    CUITitledGroup(title: "Title") {
                        Text("top edge, leading RTL")
                            .padding(.standardSpacing)
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                }

                CUITitledGroup(
                    positionSet: .leadingEdge(.bottom),
                    title: "Title"
                ) {
                    Text("The title for this is aligned vertically, at the bottom.")
                        .padding(.standardSpacing)
                        .frame(width: 120)
                }
            }
            HStack {
                CUITitledGroup(title: "Super longer title") {
                    Text("Tall\nTest\nContent")
                        .padding(.standardSpacing)
                }

                CUITitledGroup(
                    positionSet: .leadingEdge(.top),
                    title: "title", cornerRadius: 0
                ) {
                    Text("Another\nVertical\nTitle")
                        .padding(.standardSpacing)
                }
            }

            CUITitledGroup(
                positionSet: .topEdge(.center),
                title: "Much Longer Title",
                sizing: .bounds
            ) {
                Text("Test Content with a colored group that is centered. Text based labels also automatically use bounds based sizing.")
                    .foregroundColor(.black)
                    .padding(.standardSpacing)
            }
            .foregroundColor(.yellow)

            CUITitledGroup {
                Text("Group with no title")
                    .padding(.standardSpacing)
            }

            CUITitledGroup(title: "Testing position sets") {
                VStack {
                    HStack {
                        CUITitledGroup(
                            positionSet: .topEdge(.leading),
                            lineWidth: 10,
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .topEdge(.center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .topEdge(.trailing),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }
                    }

                    HStack {
                        CUITitledGroup(
                            positionSet: .bottomEdge(.leading),
                            lineWidth: 6,
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .bottomEdge(.center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .bottomEdge(.trailing),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }
                    }

                    HStack {
                        CUITitledGroup(
                            positionSet: .leadingEdge(.top),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .leadingEdge(.center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .leadingEdge(.bottom),
                            lineWidth: 6,
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }
                    }

                    HStack {
                        CUITitledGroup(
                            positionSet: .trailingEdge(.top),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .trailingEdge(.center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .trailingEdge(.bottom),
                            lineWidth: 6,
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }
                    }
                }
                .padding(.standardSpacing * 3)
            }
        }
    }
}
