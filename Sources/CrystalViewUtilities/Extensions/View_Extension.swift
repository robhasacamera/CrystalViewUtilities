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
    /// - Parameters:
    ///   - style: An instance of a type that conforms to `ShapeStyle` that SwiftUI draws behind the modified view.
    ///   - edges: The set of edges for which to ignore safe area insets when adding the background. The default value is all. Specify an empty set to respect safe area insets on all edges.
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
        /// Refer to `fullScreenCover(isPresented:onDismiss:content:)` for
        /// additional documentation. This version of full screen cover also provides a transparent
        /// background.
        /// - Parameters:
        ///   - isPresented: A binding to a Boolean value that determines whether to present the sheet.
        ///   - onDismiss: The closure to execute when dismissing the modal view.
        ///   - content: The closure to execute when dismissing the modal view.
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

        // TODO: Consider adding a convienance method for presenting a window that takes only content. There can be a closure that passes in a CUIStylizedWindow and returns some CUIStylizedWindow so it can be fully customized.
        // TODO: Document
        /// Presents a view fullscreen, optionally dimming the background.
        ///
        /// This also provides an dismissal by tapping on any any area not covered by the content, i.e. the background. When this option is enabled, tap to dismiss will occur whether or not the dimmed option is used. If the entire space of the screen is taken up, there will be no background available to tap on.
        /// - Parameters:
        ///   - isPresented: A binding to a Boolean value that determines whether to present the provided content.
        ///   - dimmed: A Boolean that indicates whether the background should be dimmed with a transparent color. Default value is `true`.
        ///   - tapBackgroundToDismiss: A Boolean to indicate if the tapping the background should dismiss the full screen content. Default value is `true`.
        ///   - onDismiss: The closure to execute when dismissing the modal view.
        ///   - content: The closure to execute when dismissing the modal view.
        func presentFullScreen<Content>(
            isPresented: Binding<Bool>,
            dimmed: Bool = true,
            tapBackgroundToDismiss: Bool = true,
            onDismiss: (() -> Void)? = nil,
            @ViewBuilder content: @escaping () -> Content
        ) -> some View where Content: View {
            FullScreenCoverContainer(
                isPresented: isPresented,
                onDismiss: onDismiss,
                dimmed: dimmed,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                originalContent: self,
                presentedContent: content()
            )
        }
    #endif
}

#if os(iOS)
    // TODO: Change this to a view modifier instead
    private struct FullScreenCoverContainer<OriginalContent, PresentedContent>: View where OriginalContent: View, PresentedContent: View {
        @State
        var internalIsPresented: Bool = false
        @State
        var alpha: CGFloat

        @Binding
        var isPresented: Bool

        var onDismiss: CUIAction?
        var originalContent: OriginalContent
        var presentedContent: PresentedContent
        var dimmed: Bool
        var tapBackgroundToDismiss: Bool

        internal init(
            isPresented: Binding<Bool>,
            onDismiss: CUIAction? = nil,
            dimmed: Bool = false,
            tapBackgroundToDismiss: Bool = false,
            originalContent: OriginalContent,
            presentedContent: PresentedContent
        ) {
            self._isPresented = isPresented
            self.onDismiss = onDismiss
            self.originalContent = originalContent
            self.presentedContent = presentedContent
            self.dimmed = dimmed
            self.tapBackgroundToDismiss = tapBackgroundToDismiss
            self._alpha = State(initialValue: (dimmed ? 0 : 1) as CGFloat)
            self.internalIsPresented = isPresented.wrappedValue
        }

        let animationTime: TimeInterval = 0.15

        var body: some View {
            // FIXME: Not sure why it needs to be nested in a ZStack to work, but it won't work unless it's nested in another view
            ZStack {
                originalContent
                    .onChange(of: isPresented, perform: { _ in
                        if dimmed, alpha > 0 {
                            withAnimation(.linear(duration: animationTime)) {
                                alpha = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + animationTime) {
                                withoutAnimation {
                                    internalIsPresented.toggle()
                                }
                            }
                        } else {
                            withoutAnimation {
                                internalIsPresented.toggle()
                            }
                        }
                    })
                    .fullScreenCover(
                        isPresented: $internalIsPresented,
                        onDismiss: onDismiss
                    ) {
                        ZStack {
                            if dimmed || tapBackgroundToDismiss {
                                Color.black
                                    .opacity(dimmed ? 0.5 : 0)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        if tapBackgroundToDismiss {
                                            isPresented = false
                                        }
                                    }
                            }

                            presentedContent
                        }
                        .opacity(alpha)
                        .background(TransparentBackground())
                        .onAppear {
                            if dimmed {
                                withAnimation(.linear(duration: animationTime)) {
                                    alpha = 1
                                }
                            }
                        }
                    }
            }
        }
    }

    // From https://stackoverflow.com/a/72124662/898984
    struct TransparentBackground: UIViewRepresentable {
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {}
    }

    struct NoAnimationFullScreenCover_Previews: PreviewProvider {
        struct Preview: View {
            @State
            var showCover = false

            var body: some View {
                ZStack {
                    Circle().foregroundColor(.yellow)
                    Button("showCover=\(showCover ? "true" : "false")") {
                        showCover.toggle()
                    }
                    .fullScreenCoverWithoutAnimation(isPresented: $showCover) {
                        ZStack {
                            Circle().foregroundColor(.gray)

                            Button("showCover=\(showCover ? "true" : "false")") {
                                showCover.toggle()
                            }
                        }
                    }
                }
            }
        }

        static var previews: some View {
            Preview()
        }
    }

    struct PresentFullScreen_Previews: PreviewProvider {
        struct Preview: View {
            @State
            var showFullScreen = false

            var body: some View {
                ZStack {
                    Circle().foregroundColor(.yellow)
                    Button("showFullScreen=\(showFullScreen ? "true" : "false")") {
                        showFullScreen.toggle()
                    }
                    .presentFullScreen(isPresented: $showFullScreen) {
                        ZStack {
                            Circle().foregroundColor(.gray)
                            Button("showFullScreen=\(showFullScreen ? "true" : "false")") {
                                showFullScreen.toggle()
                            }
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
