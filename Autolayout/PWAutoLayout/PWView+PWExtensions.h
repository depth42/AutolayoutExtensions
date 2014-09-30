//
//  NSView-PWExtensions.h
//
//  Created by Frank Illenberger on 05.11.12.
//

#if TARGET_OS_IPHONE

#define PWView UIView
#define PWControl UIControl
#define PWSize CGSize

#else

#define PWView NSView
#define PWControl NSControl
#define PWSize NSSize

#endif

@protocol PWViewHidingSlave <NSObject>

// PWHidingMasterView is the publicly available outlet which can be used in IB
// to setup hiding dependencies between views and constraints.
// If a view gets hidden, all constraints and views whose PWHidingMasterView point
// to the hidden view get hidden as well. (Hiding a constraint means nullifying its constant).
// The same goes for unhiding.
@property (nonatomic, readwrite, unsafe_unretained)  IBOutlet PWView *PWHidingMasterView;

@property (nonatomic, readwrite, getter=isPWHidden) BOOL PWHidden;

@end


#pragma mark -

@interface PWView (PWExtensions) <PWViewHidingSlave>

// PWHidingSlaves are other views or layout constraints whose PWHidingMasterView
// outlets point to the receiver.
@property (nonatomic, readonly, copy)  NSHashTable *PWHidingSlaves; // id <PWViewHidingSlave>

- (void)PWRegisterHidingSlave:(id <PWViewHidingSlave>)slave;
- (void)PWUnregisterHidingSlave:(id <PWViewHidingSlave>)slave;

// One of the strings @"width,height", @"height" or @"width" which determines which of the receiver's dimensions
// should take part in auto-collapsing when the receiver is hidden.
// This is for example useful if a hidden label should still keep its horizontal width for aligning with other labels
// but collapse vertically.
// Can be set explicity, also via user-defined runtime attributes in IB.
// If nil and the receiver is a hiding master or slave, the collapse behavior defaults to @"width,height"
@property (nonatomic, readwrite, copy) NSString *PWAutoCollapse;

@end
