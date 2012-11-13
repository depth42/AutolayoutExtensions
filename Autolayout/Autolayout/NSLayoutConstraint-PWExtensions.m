//
//  NSLayoutConstraint-PWExtensions.m
//
//  Created by Frank Illenberger on 05.11.12.
//

#import "NSLayoutConstraint-PWExtensions.h"
#import <objc/runtime.h>

@implementation NSLayoutConstraint (PWExtensions)

#pragma mark -
#pragma mark Hiding Master View

static NSString* const PWHidingMasterViewKey = @"net.projectwizards.net.hidingMasterView";

- (NSView*)PWHidingMasterView
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey);
}

- (void)setPWHidingMasterView:(NSView*)master
{
    NSView* previousMaster = self.PWHidingMasterView;
    if(master != previousMaster)
    {
        [previousMaster PWUnregisterHidingSlave:self];
        
        objc_setAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey, master, OBJC_ASSOCIATION_ASSIGN);
        
        [master PWRegisterHidingSlave:self];
    }
}

#pragma mark -
#pragma mark Original Constant

static NSString* const PWOriginalConstantKey = @"net.projectwizards.net.PWOriginalConstant";

- (NSNumber*)PWOriginalConstant
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWOriginalConstantKey);
}

- (void)setPWOriginalConstant:(NSNumber*)constant
{
    objc_setAssociatedObject(self, (__bridge const void*)PWOriginalConstantKey, constant, OBJC_ASSOCIATION_COPY);
}

#pragma mark -
#pragma mark PWHidingSlave protocol

- (void)setPWHidden:(BOOL)hidden
{
    if(hidden != self.isPWHidden)
    {
        if(hidden)
        {
            // Remember constant for later unhiding of constraint
            self.PWOriginalConstant = @(self.constant);
            self.constant = 0.0;
        }
        else
        {
            NSAssert(self.PWOriginalConstant, nil);
            self.constant = self.PWOriginalConstant.doubleValue;
            self.PWOriginalConstant = nil;
        }
    }
}

- (BOOL)isPWHidden
{
    return self.PWOriginalConstant != nil;
}

@end