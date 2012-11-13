//
//  NSView-PWExtensions.h
//
//  Created by Frank Illenberger on 05.11.12.
//

#import "NSView-PWExtensions.h"
#import "NSLayoutConstraint-PWExtensions.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

// A helper object for holding weak references
// See http://stackoverflow.com/a/13351665/43615
@interface WeakObjectHolder : NSObject
  @property (nonatomic, weak) id weakRef;
@end
@implementation WeakObjectHolder
@end


@interface NSView (PWExtensionsPrivate)
- (NSSize)PWIntrinsicContentSizeIsBase:(BOOL)isBase;        // Needed for Xcode versions prior to 4.6 DP1
@end

@implementation NSView (PWExtensions)

#pragma mark -
#pragma mark Swizzling

+ (void)load
{
    [self jr_swizzleMethod:@selector(setHidden:)
                withMethod:@selector(PWSwizzled_setHidden:)];

    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize)];
}

#pragma mark -
#pragma mark Hiding Master

static NSString* const PWHidingMasterViewKey = @"net.projectwizards.net.hidingMasterView";

- (NSView*)PWHidingMasterView
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey);
}

- (void)setPWHidingMasterView:(NSView*)master
{
    NSParameterAssert(master != self);

    NSView* previousMaster = self.PWHidingMasterView;
    if(master != previousMaster)
    {
        [previousMaster PWUnregisterHidingSlave:self];
        objc_setAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey, master, OBJC_ASSOCIATION_ASSIGN);
        [master PWRegisterHidingSlave:self];
    }
}

#pragma mark -
#pragma mark Hiding Slaves

static NSString* const PWHidingSlavesKey = @"net.projectwizards.net.hidingSlaves";

- (NSMutableSet*)PWHidingSlaves
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey);
}

- (void)PWRegisterHidingSlave:(id <PWViewHidingSlave>)slave
{
    NSParameterAssert(slave);
    NSMutableSet* slaves = objc_getAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey);
    if(!slaves)
    {
        slaves = [NSMutableSet set];
        objc_setAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey, slaves, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
	WeakObjectHolder *helper = [WeakObjectHolder new];
	helper.weakRef = slave;
    [slaves addObject:helper];
}

- (void)PWUnregisterHidingSlave:(id <PWViewHidingSlave>)slave
{
    NSParameterAssert(slave);
    [self.PWHidingSlaves removeObject:slave];
}

#pragma mark -
#pragma mark Auto collapse

static NSString* const PWAutoCollapseKey = @"net.projectwizards.net.autoCollapse";

- (NSString*)PWAutoCollapse
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWAutoCollapseKey);
}

- (void)setPWAutoCollapse:(NSString*)value
{
    objc_setAssociatedObject(self, (__bridge const void*)PWAutoCollapseKey, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark -
#pragma mark Instrinsic content size

- (NSSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:YES];
}

- (NSSize)PWIntrinsicContentSizeIsBase:(BOOL)isBase
{
    BOOL autocollapseWidth = NO;
    BOOL autocollapseHeight = NO;
    NSString* value = self.PWAutoCollapse;
    if(self.isHidden)
    {
        if(value)
        {
            autocollapseWidth  = ([value rangeOfString:@"width"].location != NSNotFound);
            autocollapseHeight = ([value rangeOfString:@"height"].location != NSNotFound);
        }
        else if(self.PWHidingMasterView != nil || self.PWHidingSlaves.count > 0)
        {
            autocollapseWidth = YES;
            autocollapseHeight = YES;
        }
    }

    NSSize size = self.PWSwizzled_intrinsicContentSize; // no recursion since methods are swizzled
    if(autocollapseWidth && (isBase || size.width != NSViewNoInstrinsicMetric))
        size.width = 0.0;
    if(autocollapseHeight && (isBase || size.height != NSViewNoInstrinsicMetric))
        size.height = 0.0;
    return size;
}

#pragma mark -
#pragma mark Hiding

- (void)PWSwizzled_setHidden:(BOOL)hidden
{
    [self PWSwizzled_setHidden:hidden]; // no recursion since methods are swizzled
    for(WeakObjectHolder *iSlaveHolder in self.PWHidingSlaves)
    {
        id <PWViewHidingSlave> iSlave = iSlaveHolder.weakRef;
        [iSlave setPWHidden:hidden];
    }

    if(self.PWHidingMasterView != nil || self.PWHidingSlaves.count > 0 || self.PWAutoCollapse != nil)
        [self invalidateIntrinsicContentSize];
}


#pragma mark -
#pragma mark PWHidingSlave protocol

- (BOOL)isPWHidden
{
    return self.isHidden;
}

- (void)setPWHidden:(BOOL)PWHidden
{
    self.hidden = PWHidden;
}
@end

#pragma mark -
#pragma mark Swizzling intrinsic content size in AppKit controls

@implementation NSButton (PWAutoLayout)
+ (void)load
{
    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize)];
}

- (NSSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:NO];
}
@end

#pragma mark -

@implementation NSTextField (PWAutoLayout)
+ (void)load
{
    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize)];
}

- (NSSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:NO];
}
@end

#pragma mark -

@implementation NSMatrix (PWAutoLayout)
+ (void)load
{
    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize)];
}

- (NSSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:NO];
}
@end

#pragma mark -

@implementation NSSlider (PWAutoLayout)
+ (void)load
{
    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize)];
}

- (NSSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:NO];
}
@end
