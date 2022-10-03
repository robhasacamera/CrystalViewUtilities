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

let DEBUG_LAYOUT_ChildSizeReader = false

/// A view that can reads the size of the view provided and provides it to the parent.
///
/// Adapted from [Wil Gieseler's](https://stackoverflow.com/users/813265/wil-gieseler) [answer on StackOverflow](https://stackoverflow.com/a/60861575/898984).
public struct CUISizeReader<Content: View, ID: Hashable>: View {
    @Binding var size: CGSize
    let id: ID
    let content: Content

    /// Creates a size reader for the view provided.
    /// - Parameters:
    ///   - size: Will be set to the size of the view provided.
    ///   - id: Used to separate values if there are multiple size readers coexisting.
    ///   - content: The view to get the size of.
    public init(
        size: Binding<CGSize>,
        id: ID,
        @ViewBuilder content:  () -> Content
    ) {
        _size = size
        self.id = id
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self,
                                    value: [id: {
                                        if DEBUG_LAYOUT_ChildSizeReader {
                                            print("proxy.size=\(proxy.size)")
                                        }
                                        return proxy.size
                                    }()])
                }
            )
            .onPreferenceChange(SizePreferenceKey<ID>.self) { preferences in
                self.size = preferences[id] ?? .zero

                if DEBUG_LAYOUT_ChildSizeReader {
                    print("onPreferenceChange self.size=\(self.size), id=\(id) preferences=\(preferences)")
                }
            }
    }


}

fileprivate struct SizePreferenceKey<ID: Hashable>: PreferenceKey {
    typealias Value = [ID: CGSize]
    static var defaultValue: Value { Value() }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        let newValue = nextValue()

        for (key, size) in newValue {
            value[key] = size
        }

        if DEBUG_LAYOUT_ChildSizeReader {
            print("reduce newValue=\(newValue), value=\(value)")
        }
    }
}
