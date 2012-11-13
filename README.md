AutolayoutExtensions
====================

The Cocoa auto-layout engine is great for designing complex, adjustable user interfaces for Mac and iOS. Out-of-the box it however lacks support for easily hiding/collapsing parts of an interface. This project fills this gap by extending the layout system.

The Problem
-----------

When implementing user interfaces, one has often the need to dynamically show and hide parts of it depending on some state. For this one usually uses the -hidden property of NSView or its associated binding. But when a view gets hidden, it is invisible but the auto-layout system still assigns space for it. 
Additionally, when you want to hide multiple views together - like a text field and its label - you also want their margin spacings to collapse when they are invisible. This can be done by grouping them in a container view. But then one loses the ability to setup constraints between them and other views in IB.  

The Solution
------------

I introduce a new public IBOutlet on NSView and NSLayoutConstraint named "PWHidingMasterView". Views and layout constraints can be made hiding slaves of a view by connecting their PWHidingMasterView outlet to the master view. 
- When a view is a slave, it gets hidden if its master is hidden.
- When a layout constraint is a slave, its constant is zeroed when its master is hidden. (It is restored back to its initial value when the master is shown again.)

Views which are a master or slave collapse to take up zero layout space in horizontal and vertical directions when they are hidden. For most cases, this default behavior is sufficient.
For finer control, I introduce the property "PWAutoCollapse" on NSView which can be set using IB's user-defined runtime attributes. With it one can reduce the collapsing behavior to a single direction. See NSView-PWExtensions.h for more information.

How To Use
----------

The code offers the following categories:
- NSView-PWExtensions (and UIView-PWExtensions for iOS)
- NSLayoutConstraint-PWExtensions
It also uses JRSwizzle (origin: https://github.com/rentzsch/jrswizzle)

The code comes with two demo projects for iOS and OS X.

Open either project and take a look at PWDocument.xib (OSX) or ViewController.xib (iOS). Watch the outlets of the controls. Note how some of them have their PWHidingMasterView outlet pointing to another control. That targeted control is the "master", those pointing to it are its slaves. The slaves will automatically hide and reduce their intrinsic size to zero (or, in case of NSLayoutConstraints, will change their 'constant' value to zero) once their master's "hidden" property is set to YES.

To use this in your own projects, add the JRSwizzle and PWAutoLayout folders to your project. Make sure that you only add one of the two "xxView-PWExtensions.m" files to your target, or you'll probably get a stack overflow when running the program. And note that while it doesn't matter which .m file you use, the Nib editor (Interface Builder) requires that you have the correctly named .h file available, or it won't offer the PWHidingMasterView outlets!

Be aware that the current implementation may not yet support all the controls you want to use, though! If in doubt, look into "NSView-PWExtensions.m". At the bottom of the source code there's a macro called "SWIZZLE_CONTROL" that takes care of intercepting the "intrinsicContentSize" function of the involved controls. Make sure to include all controls you want to use as slaves and masters.

If you've added and tested other controls, feel free to submit your additions, ideally by forking the project on github, committing changes to your fork, then issuing a "pull request".


This project's home is at https://github.com/depth42/AutolayoutExtensions
