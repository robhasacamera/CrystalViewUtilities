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

public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    ///
    /// From: https://www.avanderlee.com/swiftui/conditional-view-modifier/
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    /// Wraps actions that should be exceuted without animation.
    ///
    /// Adapted from: [Asperi's](https://stackoverflow.com/users/12299030/asperi) [answer on Stack Overflow] (https://stackoverflow.com/a/72973172/898984)
    /// - Parameter action: Action to execute without triggerring an animation.
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }

    /// Must use casting when passing in a nil or optional value.
    ///
    /// Example:
    /// ```
    /// .optionalBackground(optionalColor as Color?)
    /// ```
    func optionalBackground<S>(_ style: S?, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View where S: ShapeStyle {
        self.if(style != nil) { view in
            view.background(style!, ignoresSafeAreaEdges: edges)
        }
    }

    #if os(iOS)
        /// Embed the view inside a hosting controller.
        var asHostingController: UIViewController {
            return UIHostingController(rootView: self)
        }

        // TODO: Document
        /// Presents a Full Screen Cover, without the usual slide up animation.
        ///
        /// Refer to `fullScreenCover(isPresented:onDismiss:content:)` for additional documentation.
        /// - Parameters:
        ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet.
        ///   - onDismiss: The closure to execute when dismissing the modal view.
        ///   - content: A closure that returns the content of the modal view.
        func fullScreenCoverWithoutAnimation<Content>(
            isPresented: Binding<Bool>,
            onDismiss: (() -> Void)? = nil,
            @ViewBuilder content: @escaping () -> Content
        ) -> some View where Content: View {
            FullScreenCoverContainer(
                isPresented: isPresented,
                onDismiss: onDismiss,
                originalContent: self,
                presentedContent: content()
            )
        }
    #endif
}

private struct FullScreenCoverContainer<OriginalContent, PresentedContent>: View where OriginalContent: View, PresentedContent: View {
    @State
    var internalIsPresented: Bool = false

    @Binding
    var isPresented: Bool

    var onDismiss: CUIAction?

    var originalContent: OriginalContent
    var presentedContent: PresentedContent

    internal init(
        isPresented: Binding<Bool>,
        onDismiss: CUIAction? = nil,
        originalContent: OriginalContent,
        presentedContent: PresentedContent
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.originalContent = originalContent
        self.presentedContent = presentedContent
        self.internalIsPresented = isPresented.wrappedValue
    }

    var body: some View {
        // FIXME: Not sure why it needs to be nested in a ZStack to work, but it won't work unless it's nested in another view
        ZStack {
            originalContent
                .onChange(of: isPresented, perform: { _ in
                    withoutAnimation {
                        internalIsPresented.toggle()
                    }
                })
                .fullScreenCover(
                    isPresented: $internalIsPresented,
                    onDismiss: onDismiss
                ) {
                    presentedContent
                }
        }
    }
}

#if os(iOS)
    struct NoAnimationFullScreenCover_Previews: PreviewProvider {
        struct Preview: View {
            @State
            var showCover = false
            @State
            var showAlert = false
            @State
            var alpha: CGFloat = 0.0

            var body: some View {
                Button("showCover=\(showCover ? "true" : "false")") {
                    showCover.toggle()
                    showAlert = true
                }
                .fullScreenCoverWithoutAnimation(isPresented: $showCover) {
                    ZStack {
                        Color.gray
                            .onAppear {
                                withAnimation {
                                    alpha = 1.0
                                }
                            }
                            // FIXME: This won't ever trigger. Will need to make my own present with fade
                            .onDisappear {
                                withAnimation {
                                    alpha = 0.0
                                }
                            }
                            .opacity(alpha)

                        Button("showCover=\(showCover ? "true" : "false")") {
                            showCover.toggle()
                            showAlert = true
                        }
                    }
                }
            }
        }

        static var previews: some View {
            Preview()
        }
    }
#endif
