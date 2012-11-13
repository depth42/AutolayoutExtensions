//
//  NSObject-PWExtensions.m
//
//  Created by Frank Illenberger on 05.11.12.
//

#import "NSObject-PWExtensions.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (PWExtensions)

+ (void)exchangeMethod:(SEL)origSel withMethod:(SEL)newSel
{
    NSParameterAssert(origSel);
    NSParameterAssert(newSel);
    
    Class class = self;

    Method origMethod = class_getInstanceMethod(class, origSel);
    if (!origMethod)
        origMethod = class_getClassMethod(class, origSel);

    NSAssert(origMethod, nil);
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!newMethod)
        newMethod = class_getClassMethod(class, newSel);

    NSAssert(newMethod, nil);
    NSAssert(origMethod != newMethod, nil);

    method_exchangeImplementations(origMethod, newMethod);
}
@end


