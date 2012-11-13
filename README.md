AutolayoutExtensions
====================

The Cocoa auto-layout engine is great for designing complex, adjustable user interfaces for the mac and iOS. Out-of-the box it however lacks support for easily hiding/collapsing parts of an interface. This project fills this gap by extending the layout system.

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


The code consists of the following categories:

- NSView-PWExtensions
- NSObject-PWExtensions
- NSLayoutConstraint-PWExtensions

It is embedded into a small demo application.
It is implemented for the Mac platform but can easily be adjusted to work on iOS as well.
