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

public enum CUIPositionSet {
    @Environment(\.layoutDirection)
    static var layoutDirection

    case topEdge(HorizontalAlignment)
    case bottomEdge(HorizontalAlignment)
    case leadingEdge(VerticalAlignment)
    case trailingEdge(VerticalAlignment)

    var isHorizontal: Bool {
        switch self {
        case .topEdge(_): fallthrough
        case .bottomEdge(_):
            return true
        case .leadingEdge(_): fallthrough
        case .trailingEdge(_):
            return false
        }
    }

    var isVertical: Bool {
        return !isHorizontal
    }

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
}
