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

/// A text label that can be rotated by 90 degrees.
///
/// This is used by ``CUITitledGroup`` when displaying a rotated label along the leading or trailing edge.
public struct CUITitledGroupTextLabel: View {
    internal init(text: String, isRotated: Bool) {
        self.text = text
        self.isRotated = isRotated
    }

    @State
    var id = UUID()
    @State
    var originalSize: CGSize = .zero

    let text: String
    let isRotated: Bool

    public var body: some View {
        CUIChildSizeReader(size: $originalSize, id: id) {
            Text(text)
                .font(.subheadline)
                .rotationEffect(isRotated ? Angle(degrees: 270) : Angle(degrees: 0))
        }
        .padding(.vertical, isRotated ? (originalSize.width - originalSize.height).half : 0)
        .padding(.horizontal, isRotated ? (originalSize.height - originalSize.width).half : 0)
    }
}

struct CUITitledGroupTextLabel_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CUITitledGroupTextLabel(text:"test label", isRotated: true)

            CUITitledGroupTextLabel(text:"test label", isRotated: false)
        }
    }
}
