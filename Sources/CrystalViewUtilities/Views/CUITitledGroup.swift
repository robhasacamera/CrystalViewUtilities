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

    var positionSet: PositionSet
    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var label: Label
    var content: Content

    @State
    var labelSize: CGSize = .zero

    // TODO: Need to provide different alignment options, but they need to make sense.
    // When text is provided, it's automatically rotated on it's side if going on a horizontal edge
    public init(
        positionSet: PositionSet = .horizontal(.top, .leading),
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

    func labelView(includeBackground: Bool) -> some View {
        Group {
            CUIChildSizeReader(size: $labelSize, id: id) {
                label
                    .padding(
                        layoutInfo.labelToStrokePaddingEdge,
                        .standardSpacing / 2
                    )
                    .background(includeBackground ? .gray : .clear)
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
    }

    private var layoutInfo: LayoutInfo {
        switch positionSet {
        case .horizontal(let hEdge, let hAlignment):
            let labelToStrokePaddingEdge: Edge.Set = .horizontal
            let labelToOuterPaddingEdge: Edge.Set = hEdge == .top ? .top : .bottom
            let labelToOuterPaddingLength: CGFloat = (labelSize.height - lineWidth) / 2
            // FIXME: This is still a weird fix, it looks like label height isn't taken into account for the overlay
            let y: CGFloat = lineWidth / 2 + (hEdge == .top ? 0 : labelSize.height - lineWidth)

            switch hAlignment {
            case .center:
                return LayoutInfo(
                    alignment: hEdge == .top ? .top : .bottom,
                    position: CGPoint(
                        x: labelSize.width / 2,
                        y: y
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            case .trailing:
                return LayoutInfo(
                    alignment: hEdge == .top ? .topTrailing : .bottomTrailing,
                    position: CGPoint(
                        x: labelSize.width / 2 - cornerRadius,
                        y: y
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            case .leading: fallthrough
            default:
                return LayoutInfo(
                    alignment: hEdge == .top ? .topLeading : .bottomLeading,
                    position: CGPoint(
                        x: labelSize.width / 2 + cornerRadius,
                        y: y
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            }
        case .vertical(let vEdge, let vAlignment):
            let labelToStrokePaddingEdge: Edge.Set = .vertical
            let labelToOuterPaddingEdge: Edge.Set = vEdge == .leading ? .leading : .trailing
            let labelToOuterPaddingLength: CGFloat = (labelSize.width - lineWidth) / 2
            // FIXME: This is still a weird fix, it looks like label width isn't taken into account for the overlay
            let x: CGFloat = lineWidth / 2 + (vEdge == .leading ? 0 : labelSize.width - lineWidth)

            switch vAlignment {
            case .center:
                return LayoutInfo(
                    alignment: vEdge == .leading ? .leading : .trailing,
                    position: CGPoint(
                        x: x,
                        y: labelSize.height / 2
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            case .bottom:
                return LayoutInfo(
                    alignment: vEdge == .leading ? .bottomLeading : .bottomTrailing,
                    position: CGPoint(
                        x: x,
                        y: labelSize.height / 2 - cornerRadius
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            case .top: fallthrough
            default:
                return LayoutInfo(
                    alignment: vEdge == .leading ? .topLeading : .topTrailing,
                    position: CGPoint(
                        x: x,
                        y: labelSize.height / 2 + cornerRadius
                    ),
                    labelToStrokePaddingEdge: labelToStrokePaddingEdge,
                    labelToOuterPaddingEdge: labelToOuterPaddingEdge,
                    labelToOuterPaddingLength: labelToOuterPaddingLength
                )
            }
        }
    }

    public var body: some View {
        content
            // TODO: Need to make this a passed in property
            .padding(.standardSpacing * 2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: lineWidth)
                    .padding(lineWidth / 2)
            )
            .reverseMask(alignment: layoutInfo.alignment) {
                labelView(includeBackground: true)
                    .fixedSize()
            }
            .overlay(alignment: layoutInfo.alignment) {
                labelView(includeBackground: false)
                    .fixedSize()
            }
            .padding(
                layoutInfo.labelToOuterPaddingEdge,
                layoutInfo.labelToOuterPaddingLength
            )
    }

    public enum PositionSet {
        case horizontal(HorizontalEdge, HorizontalAlignment)
        case vertical(VerticalEdge, VerticalAlignment)
    }
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
        positionSet: PositionSet = .horizontal(.top, .leading),
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
        positionSet: PositionSet = .horizontal(.top, .leading),
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
