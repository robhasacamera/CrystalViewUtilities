#  View Extension

### Conditional modifiers

``CUIChildSizeReader/if(_:transform:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Applies the given transform if the given condition evaluates to `true`.

``CUIChildSizeReader/optionalBackground(_:ignoresSafeAreaEdges:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Must use casting when passing in a nil or optional value.

### Presenting other views

``CUIChildSizeReader/fullScreenCoverWithoutAnimation(isPresented:onDismiss:content:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Presents a Full Screen Cover, without the usual slide up animation.

``CUIChildSizeReader/presentFullScreen(isPresented:dimmed:tapBackgroundToDismiss:onDismiss:content:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Presents a view fullscreen, optionally dimming the background.

### Integrating with UIKit

``CUIChildSizeReader/asHostingController``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Embed the view inside a hosting controller.

### Animation

``CUIChildSizeReader/withoutAnimation(action:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Wraps actions that should be exceuted without animation.

### Masking views

``CUIChildSizeReader/cornerRadius(_:corners:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Rounds the provided corners of the view.

``CUIChildSizeReader/reverseMask(alignment:_:)``

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Masks this view using the inverse alpha channel of a given view.
