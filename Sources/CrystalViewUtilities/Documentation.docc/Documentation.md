# ``CrystalViewUtilities``

Contains useful extensions and views for working with SwiftUI.

## Overview

This package is a base for Crystal UI. It provides several utility views and extensions. The extensions provide convenience functions, accessors, and standards used throughout Crystal UI. Utilities views are both a base for other Crystal UI views and are provided as part the utilities that Crystal Ui provides.
 
 [Unfortunately DocC doesn't currently support generating documentation for extensions in external libraries.](https://forums.swift.org/t/document-extensions-to-external-types-using-docc/56060) Documentation links are available to the View Extension via a loophole. Extensions are also available for:
- `Alignment`
- `CGFloat`
- `Color`
- `GeometryProxy`
- `Image`
- `UIScreen`

## Topics

### Views

- ``CUISizeReader``
- ``CUIChildGeometryReader``
- ``CUIFlowLayout``
- ``CUIAdaptiveStackView``

### Shapes
- ``CUIRoundedCornerShape``

### View Extension

- ``CUISizeReader/if(_:transform:)``
- ``CUISizeReader/optionalBackground(_:ignoresSafeAreaEdges:)``
- ``CUISizeReader/presentFullScreen(isPresented:dimmed:tapBackgroundToDismiss:onDismiss:content:)``
- ``CUISizeReader/fullScreenCoverWithoutAnimation(isPresented:onDismiss:content:)``
- ``CUISizeReader/asHostingController``
- ``CUISizeReader/withoutAnimation(action:)``
- ``CUISizeReader/reverseMask(alignment:_:)``
- ``CUISizeReader/cornerRadius(_:corners:)``

