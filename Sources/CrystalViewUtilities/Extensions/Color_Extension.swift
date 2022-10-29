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

public extension Color {
    // MARK: - Transparency modifiers

    /// Returns the a very transparent varient of the color.
    ///
    /// This will be less opaque then ``regularTransparent``.
    var veryTransperent: Color {
        opacity(0.25)
    }

    /// Returns the a transparent varient of the color.
    var regularTransparent: Color {
        opacity(0.5)
    }

    /// Convience call for ``regularTransparency``.
    var transparent: Color {
        regularTransparent
    }

    /// Returns the a lightly transparent varient of the color.
    ///
    /// This will be more opaque then ``regularTransparent``.
    var lightlyTransperent: Color {
        opacity(0.75)
    }
}
