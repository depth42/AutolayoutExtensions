//
//  NSView-PWExtensions.h
//
//  Created by Frank Illenberger on 05.11.12.
//

#if !TARGET_OS_IPHONE

#import "PWView+PWExtensions.h"

@interface NSView (PWExtensions) <PWViewHidingSlave>

@property (nonatomic, readwrite, unsafe_unretained)  IBOutlet PWView *PWHidingMasterView;

@end

#endif
