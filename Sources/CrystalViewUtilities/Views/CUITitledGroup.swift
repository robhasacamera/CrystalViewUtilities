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

    public init(
        positionSet: CUIPositionSet = .horizontal(.top, .leading),
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
        case .horizontal(let hEdge, let hAlignment):
            return horizontalLayoutInfo(hEdge, hAlignment)
        case .vertical(let vEdge, let vAlignment):
            return verticalLayoutInfo(vEdge, vAlignment)
        }
    }

    public var body: some View {
        content
            .padding(lineWidth.half)
            // Note: 0 is specified instead of nil as it was cauing the
            // minHeight to be assigned as the height otherwise.
            .frame(
                minWidth: layoutInfo.labelToStrokePaddingEdge == .horizontal
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

public enum CUIPositionSet {
    case horizontal(CUIHorizontalEdge, HorizontalAlignment)
    case vertical(CUIVerticalEdge, VerticalAlignment)
}

enum BezierCutPosition {
    case topEdge(HorizontalAlignment)
    case bottomEdge(HorizontalAlignment)
    case leftEdge(VerticalAlignment)
    case rightEdge(VerticalAlignment)

    enum HorizontalAlignment {
        case left
        case center
        case right
    }

    enum VerticalAlignment {
        case top
        case center
        case bottom
    }
}

enum PositionSet {
    @Environment(\.layoutDirection)
    static var layoutDirection

    case topEdge(HorizontalAlignment)
    case bottomEdge(HorizontalAlignment)
    case leadingEdge(VerticalAlignment)
    case trailingEdge(VerticalAlignment)

    var hAlignment: HorizontalAlignment? {
        switch self {
        case .topEdge(let alignment):
            return alignment
        case .bottomEdge(let alignment):
            return alignment
        case .leadingEdge: fallthrough
        case .trailingEdge:
            return nil
        }
    }

    var vAlignment: VerticalAlignment? {
        switch self {
        case .topEdge: fallthrough
        case .bottomEdge:
            return nil
        case .leadingEdge(let alignment):
            return alignment
        case .trailingEdge(let alignment):
            return alignment
        }
    }

    var edge: Edge {
        switch self {
        case .topEdge:
            return .top
        case .bottomEdge:
            return .bottom
        case .leadingEdge:
            return .leading
        case .trailingEdge:
            return .trailing
        }
    }

    var axis: Axis {
        switch self {
        case .topEdge: fallthrough
        case .bottomEdge:
            return .horizontal
        case .leadingEdge: fallthrough
        case .trailingEdge:
            return .vertical
        }
    }

    var hCutAlignment: BezierCutPosition.HorizontalAlignment? {
        guard let hAlignment else {
            return nil
        }

        switch hAlignment {
        case .leading:
            return PositionSet.layoutDirection == .rightToLeft ? .right : .left
        case .center:
            return .center
        case .trailing:
            return PositionSet.layoutDirection == .rightToLeft ? .left : .right
        default:
            return nil
        }
    }

    var vCutAlignment: BezierCutPosition.VerticalAlignment? {
        guard let vAlignment else {
            return nil
        }

        switch vAlignment {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        default:
            return nil
        }
    }

    var cutPosition: BezierCutPosition {
        let hCutAlignment = hCutAlignment ?? .center
        let vCutAlignment = vCutAlignment ?? .center

        switch self {
        case .topEdge:
            return .topEdge(hCutAlignment)
        case .bottomEdge:
            return .bottomEdge(hCutAlignment)
        case .leadingEdge:
            return Self.layoutDirection == .rightToLeft
                ? .rightEdge(vCutAlignment)
                : .leftEdge(vCutAlignment)
        case .trailingEdge:
            return Self.layoutDirection == .rightToLeft
                ? .leftEdge(vCutAlignment)
                : .rightEdge(vCutAlignment)
        }
    }
}

public enum CUIHorizontalEdge {
    case top
    case bottom
}

public enum CUIVerticalEdge {
    case leading
    case trailing
}

public extension CUITitledGroup where Label == CUITitledGroupTextLabel {
    init(
        positionSet: CUIPositionSet = .horizontal(.top, .leading),
        title: String,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        sizing: SizingOption = .bounds,
        @ViewBuilder content: () -> Content
    ) {
        let isRotated: Bool
        switch positionSet {
        case .horizontal:
            isRotated = false
        case .vertical:
            isRotated = true
        }

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
    init(
        positionSet: CUIPositionSet = .horizontal(.top, .leading),
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
                    positionSet: .vertical(.leading, .bottom),
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
                    positionSet: .vertical(.trailing, .top),
                    title: "title", cornerRadius: 0
                ) {
                    Text("Another\nVertical\nTitle")
                        .padding(.standardSpacing)
                }
            }

            CUITitledGroup(
                positionSet: .horizontal(.top, .center),
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
                            positionSet: .horizontal(.top, .leading),
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
                            positionSet: .horizontal(.top, .center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .horizontal(.top, .trailing),
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
                            positionSet: .horizontal(.bottom, .leading),
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
                            positionSet: .horizontal(.bottom, .center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .horizontal(.bottom, .trailing),
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
                            positionSet: .vertical(.leading, .top),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .vertical(.leading, .center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .vertical(.leading, .bottom),
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
                            positionSet: .vertical(.trailing, .top),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .vertical(.trailing, .center),
                            cornerRadius: 5
                        ) {
                            Circle()
                                .foregroundColor(.yellow)
                                .frame(width: 10, height: 10)
                        } content: {
                            testContent
                        }

                        CUITitledGroup(
                            positionSet: .vertical(.trailing, .bottom),
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
