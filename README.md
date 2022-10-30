# CrystalViewUtilities

[![package build workflow](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/ios-package.yml/badge.svg)](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/ios-package.yml)
[![package build workflow](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/mac-package.yml/badge.svg)](https://github.com/robhasacamera/CrystalViewUtilities/actions/workflows/mac-package.yml)

Contains useful extensions and views for working with SwiftUI.

## Installation

CrystalViewUtilities supports Swift Package Manager. To use it the following to your `Package.swift` file:

```
dependencies: [
    .package(name: "CrystalViewUtilities", url: "https://github.com/robhasacamera/CrystalViewUtilities.git", from: "0.9.2")
],
```

## Future Plans

This package will be added to as more useful utilities are discovered while building Cyrstal UI.

// TODO: Write script, using some of the swift command lines tools I just found, to:
1. Automatically creates or updates documentation files for any `_Extension` file
2. Add a link to extension documentation in the main doc file under the Extensions topic
3. Add the methods from the extension to the extension documentation, linked to the detailed doc, with a one liner describing the method
4. Generate the detail documents for each method
Bonuses:
5. Automatically add new classes, structs, views, shapes, layouts to the main documentation
6. Run the Docc command to update the documentation
7. Run the command to update the readme file's version tag to match the current branch version
8. Automatically generate the version files needed for the SwiftPacage index to update to the version number of the documentation.

// TODO: Write a script that automatically pulls, gets the latest tag, and ask what new version type you want (major, minor, bugfix)

// TODO: Write a script that runs the documentation script and then pushes to the repo.

// TODO: Write some snapshot/unit tests for these things.
