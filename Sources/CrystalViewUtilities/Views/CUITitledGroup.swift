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

// FIXME: Stroke looks weird as is.
struct CUITitledGroup<Content: View>: View {
    @State
    var id = UUID()

    var title: String?
    var content: Content

    public init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    func titleView(includeBackground: Bool) -> some View {
        Group {
            if let title {
                CUIChildSizeReader(id: id) { size in
                    Text(title)
                        .padding(.standardSpacing / 2)
                        .background(includeBackground ? .gray : .clear)
                        .position(
                            x: size.width / 2 + .standardSpacing * 1.5,
                            y: 0
                        )
                }

            }
        }
    }

    public var body: some View {
        content
            .padding(.standardSpacing * 2)
            .overlay(
                RoundedRectangle(cornerRadius: .cornerRadius)
                    .stroke(.blue, lineWidth: 2)
            )
            .reverseMask(alignment: .topLeading) {
                titleView(includeBackground: true)
                    .fixedSize()

            }
            .overlay(alignment: .topLeading) {
                titleView(includeBackground: false)
                    .fixedSize()
            }
    }
}

struct CUITitledGroup_Previews: PreviewProvider {
    static var previews: some View {
        CUITitledGroup(title: "Title") {
            Text("Test content")
        }
    }
}
