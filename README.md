# CrystalViewUtilities

Contains useful extensions and views for working with SwiftUI.

[![package build workflow](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/ios-package.yml/badge.svg)](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/ios-package.yml)
[![package build workflow](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/mac-package.yml/badge.svg)](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/mac-package.yml)

## Installation

CrystalViewUtilities supports Swift Package Manager. To use it the following to your `Package.swift` file:

```
dependencies: [
    .package(name: "CrystalViewUtilities", url: "https://github.com/robhasacamera/CrystalViewUtilities.git", from: "0.10.0")
],
```

## Future Plans

This package will be added to as more useful utilities are discovered while building Cyrstal UI.

1. Create snapshot and unit tests.
2. Create scripts below to automatic standard processes.

### Script that automatically update DocC articles
1. Automatically creates or updates documentation files for any `_Extension` file.
2. Add a link to extension documentation in the main doc file under the Extensions topic.
3. Add the methods from the extension to the extension documentation, linked to the detailed doc, with a one liner describing the method.
4. Generate the detail documents for each method.
5. Automatically add new classes, structs, views, shapes, layouts to the main documentation.
6. Run the DocC command to update the documentation.
7. Automatically generate the version files needed for the Swift Package Index to update to the version number of the documentation.

### Script that updates the version
1. Automatically switches to main, pulls the latest commits and tags.
2. Asks what new version type you want (major, minor, bugfix).
3. Creates a new branch for the next version and switches to it.
4. Update the readme file's version tag to match the current branch version.

### Script that runs the DocC script and pushes
1. Run the DocC script.
2. Pushes code to the repo.
