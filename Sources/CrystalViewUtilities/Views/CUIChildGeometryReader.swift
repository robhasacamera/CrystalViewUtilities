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

/// A view that can reads the geometry of the view provided and provides it to the parent.
///
/// This is different from SwiftUI's `GeometryReader` as it provides the geometry for the child instead of geometry for the parent.
///
/// Adapted from [Wil Gieseler's](https://stackoverflow.com/users/813265/wil-gieseler) [answer on StackOverflow](https://stackoverflow.com/a/60861575/898984).
public struct CUIChildGeometryReader<Content: View, ID: Hashable>: View {
    @State
    var proxy: GeometryProxy? = nil
    let id: ID
    let content: (GeometryProxy?) -> Content

    /// Creates a GeometryReader reader for the view provided.
    ///
    /// The proxy provided will provide geometry for the child view. Caution should be used when using the child's geometry to size the child, as it is easy to create an infinite loop.
    /// - Parameters:
    ///   - id: Used to separate values if there are multiple size readers coexisting.
    ///   - content: The view to get the geometry for.
    public init(
        id: ID,
        @ViewBuilder content: @escaping (GeometryProxy?) -> Content
    ) {
        self.id = id
        self.content = content
    }

    public var body: some View {
        content(proxy)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: GeometryPreferenceKey.self,
                            value: [id: proxy]
                        )
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
    }
}
