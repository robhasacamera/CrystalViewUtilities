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
public struct CUIChildGeometryReader<Content: View, ID: Hashable>: View {
    @Binding
    var proxy: GeometryProxy
    let id: ID
    let content: Content

    /// Creates a size reader for the view provided.
    /// - Parameters:
    ///   - size: Will be set to the size of the view provided.
    ///   - id: Used to separate values if there are multiple size readers coexisting.
    ///   - content: The view to get the size of.
    public init(
        proxy: Binding<GeometryProxy>,
        id: ID,
        @ViewBuilder content:  () -> Content
    ) {
        _proxy = proxy
        self.id = id
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: GeometryPreferenceKey.self, value: [id: {
                            if DEBUG_LAYOUT_ChildSizeReader {
                                print("proxy=\(proxy)")
                            }
                            return proxy
                        }()])
                }
            )
            .onPreferenceChange(GeometryPreferenceKey<ID>.self) { preferences in
                guard let proxy = preferences[id] else {
                    // TODO: Add warning

                    return
                }

                self.proxy = proxy
            }
    }
}

fileprivate struct GeometryPreferenceKey<ID: Hashable>: PreferenceKey {
    typealias Value = [ID: GeometryProxy]
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
