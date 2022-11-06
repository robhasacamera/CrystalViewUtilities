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
    @State
    var id = UUID()

    var positionSet: CUIPositionSet
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var label: Label
    var content: Content

    @State
    var labelSize: CGSize = .zero

    public init(
        positionSet: CUIPositionSet = .horizontal(.top, .leading),
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.positionSet = positionSet
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.label = label()
        self.content = content()
    }

    var labelView: some View {
        // TODO: Probably don't need the group
        Group {
            CUIChildSizeReader(size: $labelSize, id: id) {
                label
                    .padding(
                        layoutInfo.labelToStrokePaddingEdge,
                        .standardSpacing / 2
                    )
                    .position(layoutInfo.position)
            }
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

    private var layoutInfo: LayoutInfo {
        switch positionSet {
        case .horizontal(let hEdge, let hAlignment):
            // FIXME: This is still a weird fix, it looks like label height isn't taken into account for the overlay
            let y: CGFloat = hEdge == .top ? 0 : labelSize.height

            let alignment: Alignment
            let position: CGPoint

            switch hAlignment {
            case .center:
                alignment = hEdge == .top ? .top : .bottom
                position = CGPoint(
                    x: labelSize.width / 2,
                    y: y
                )
            case .trailing:
                alignment = hEdge == .top ? .topTrailing : .bottomTrailing
                position = CGPoint(
                    x: labelSize.width / 2 - cornerRadius,
                    y: y
                )
            case .leading: fallthrough
            default:
                alignment = hEdge == .top ? .topLeading : .bottomLeading
                position = CGPoint(
                    x: labelSize.width / 2 + cornerRadius,
                    y: y
                )
            }

            return LayoutInfo(
                alignment: alignment,
                position: position,
                labelToStrokePaddingEdge: .horizontal,
                labelToOuterPaddingEdge: hEdge == .top ? .top : .bottom,
                labelToOuterPaddingLength: (labelSize.height - lineWidth).half,
                strokeCutLength: labelSize.width
            )
        case .vertical(let vEdge, let vAlignment):
            // FIXME: This is still a weird fix, it looks like label width isn't taken into account for the overlay
            let x: CGFloat = vEdge == .leading ? 0 : labelSize.width

            let alignment: Alignment
            let position: CGPoint

            switch vAlignment {
            case .center:
                alignment = vEdge == .leading ? .leading : .trailing
                position = CGPoint(
                    x: x,
                    y: labelSize.height / 2
                )
            case .bottom:
                alignment = vEdge == .leading ? .bottomLeading : .bottomTrailing
                    position = CGPoint(
                        x: x,
                        y: labelSize.height / 2 - cornerRadius
                    )
            case .top: fallthrough
            default:
                alignment = vEdge == .leading ? .topLeading : .topTrailing
                    position = CGPoint(
                        x: x,
                        y: labelSize.height / 2 + cornerRadius
                    )
            }

            return LayoutInfo(
                alignment: alignment,
                position: position,
                labelToStrokePaddingEdge: .vertical,
                labelToOuterPaddingEdge: vEdge == .leading ? .leading : .trailing,
                labelToOuterPaddingLength: (labelSize.width - lineWidth) / 2,
                strokeCutLength: labelSize.height
            )
        }
    }

    public var body: some View {
        content
            // TODO: Add min width or height to make sure there is alway enough room for the label
            // To create this I can just combine the rounded rect shape with the masked rect, I think
            // FIXME: Need to be able to remove this, so it's only there when needed. However, this will make the text default content init more difficult as I'm not sure how to add it there since padding returns some View. I could create a custom text wrapper that makes the padding and rotation calc for me, and use that as the type. I think that would work well.
            .padding(.standardSpacing * 2)
            .overlay(
                CUIRoundedCornerShape(radius: cornerRadius)
                    .cutPath(
                        positionSet: positionSet,
                        length: layoutInfo.strokeCutLength
                    )
                    .stroke(lineWidth: lineWidth)
            )
            .overlay(alignment: layoutInfo.alignment) {
                labelView
                    .fixedSize()
            }
            .padding(
                layoutInfo.labelToOuterPaddingEdge,
                layoutInfo.labelToOuterPaddingLength
            )
            // TODO: Document that outer dimensions will be affected by the linewidth, i.e. if content is 50x50 & linewidth is 2, final demensions will be 52x52 before taking in account the label. Though this would be a layout nightmare, Maybe I should reconsider or make this a separate option
            .padding(lineWidth / 2)
    }
}

public enum CUIPositionSet {
    case horizontal(HorizontalEdge, HorizontalAlignment)
    case vertical(VerticalEdge, VerticalAlignment)
}

public enum HorizontalEdge {
    case top
    case bottom
}

public enum VerticalEdge {
    case leading
    case trailing
}

public extension CUITitledGroup where Label == Text {
    init(
        positionSet: CUIPositionSet = .horizontal(.top, .leading),
        title: String,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            positionSet: positionSet,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius
        ) {
            Text(title)
                .font(.subheadline)
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
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            positionSet: positionSet,
            lineWidth: lineWidth,
            cornerRadius: cornerRadius
        ) {
            EmptyView()
        } content: {
            content()
        }
    }
}

struct CUITitledGroup_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CUITitledGroup(title: "Title") {
                Text("Test Content")
            }

            CUITitledGroup(title: "Title") {
                Text("Tall\nTest\nContent")
            }

            CUITitledGroup(title: "Title") {
                Text("Test Content with a colored group")
                    .foregroundColor(.black)
            }
            .foregroundColor(.yellow)

            CUITitledGroup {
                Text("Group with no title")
            }

            HStack {
                CUITitledGroup(
                    positionSet: .horizontal(.top, .leading),
                    lineWidth: 10,
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .horizontal(.top, .center),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .horizontal(.top, .trailing),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }
            }

            HStack {
                CUITitledGroup(
                    positionSet: .horizontal(.bottom, .leading),
                    lineWidth: 6,
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .horizontal(.bottom, .center),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .horizontal(.bottom, .trailing),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }
            }

            HStack {
                CUITitledGroup(
                    positionSet: .vertical(.leading, .top),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .vertical(.leading, .center),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .vertical(.leading, .bottom),
                    lineWidth: 6,
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }
            }

            HStack {
                CUITitledGroup(
                    positionSet: .vertical(.trailing, .top),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .vertical(.trailing, .center),
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }

                CUITitledGroup(
                    positionSet: .vertical(.trailing, .bottom),
                    lineWidth: 6,
                    cornerRadius: 20
                ) {
                    Circle()
                        .foregroundColor(.yellow)
                        .frame(width: 10, height: 10)
                } content: {
                    RoundedRectangle(cornerRadius: .cornerRadius)
                        .frame(width: 60, height: 60)
                }
            }
        }
    }
}
