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

    var lineWidth: CGFloat
    var cornerRadius: CGFloat
    var label: Label
    var content: Content

    @State
    var titleSize: CGSize = .zero

    public init(
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.label = label()
        self.content = content()
    }

    func titleView(includeBackground: Bool) -> some View {
        Group {
            CUIChildSizeReader(size: $titleSize, id: id) {
                label
                    .padding(.horizontal, .standardSpacing / 2)
                    .background(includeBackground ? .gray : .clear)
                    .position(
                        x: titleSize.width / 2 + cornerRadius,
                        y: lineWidth / 2
                    )
            }
        }
    }

    public var body: some View {
        content
            .padding(.standardSpacing * 2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: lineWidth)
                    .padding(lineWidth / 2)
            )
            .reverseMask(alignment: .topLeading) {
                titleView(includeBackground: true)
                    .fixedSize()
            }
            .overlay(alignment: .topLeading) {
                titleView(includeBackground: false)
                    .fixedSize()
            }
            .padding(.top, (titleSize.height - lineWidth) / 2)
    }
}

public extension CUITitledGroup where Label == Text {
    init(
        title: String,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
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
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = .cornerRadius,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
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

            CUITitledGroup(cornerRadius: 20) {
                Circle()
                    .foregroundColor(.yellow)
                    .frame(width: 10, height: 10)
            } content: {
                Text("Group with custom label\nand larger corner radius")
            }
        }
    }
}
