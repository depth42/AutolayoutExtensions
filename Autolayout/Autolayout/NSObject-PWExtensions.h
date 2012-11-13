//
//  NSObject-PWExtensions.h
//
//  Created by Frank Illenberger on 05.11.12.
//

@interface NSObject (PWExtensions)

// Swizzles methods
+ (void)exchangeMethod:(SEL)origSel withMethod:(SEL)newSel;

@end


