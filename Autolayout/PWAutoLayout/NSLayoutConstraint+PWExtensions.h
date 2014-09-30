//
//  NSLayoutConstraint-PWExtensions.h
//
//  Created by Frank Illenberger on 05.11.12.
//

#import "UIView+PWExtensions.h"
#import "NSView+PWExtensions.h"


@interface NSLayoutConstraint (PWExtensions) <PWViewHidingSlave>

@property (nonatomic, readwrite, unsafe_unretained) IBOutlet PWView *PWHidingMasterView;

@end
