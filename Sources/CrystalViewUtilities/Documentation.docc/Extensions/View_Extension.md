#  View Extension

### Conditional modifiers

``CUISizeReader/if(_:transform:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Applies the given transform if the given condition evaluates to `true`.

``CUISizeReader/optionalBackground(_:ignoresSafeAreaEdges:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Must use casting when passing in a nil or optional value.

### Presenting other views

``CUISizeReader/fullScreenCoverWithoutAnimation(isPresented:onDismiss:content:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Presents a Full Screen Cover, without the usual slide up animation.

``CUISizeReader/presentFullScreen(isPresented:dimmed:tapBackgroundToDismiss:onDismiss:content:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Presents a view fullscreen, optionally dimming the background.

### Integrating with UIKit

``CUISizeReader/asHostingController``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Embed the view inside a hosting controller.

### Animation

``CUISizeReader/withoutAnimation(action:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Wraps actions that should be exceuted without animation.

### Masking views

``CUISizeReader/cornerRadius(_:corners:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rounds the provided corners of the view.

``CUISizeReader/reverseMask(alignment:_:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Masks this view using the inverse alpha channel of a given view.
