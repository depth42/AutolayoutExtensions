//
//  NSView-PWExtensions.m
//
//  Created by Frank Illenberger on 05.11.12.
//

#import "NSView+PWExtensions.h"
#import "NSLayoutConstraint+PWExtensions.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

@interface PWView (PWExtensionsPrivate)
- (PWSize)PWIntrinsicContentSizeIsBase:(BOOL)isBase;   // Needed for Xcode versions prior to 4.6 DP1
@end

@implementation PWView (PWExtensions)

#pragma mark - Swizzling

+ (void)load
{
    [self jr_swizzleMethod:@selector(setHidden:)
                withMethod:@selector(PWSwizzled_setHidden:) error:nil];

    [self jr_swizzleMethod:@selector(intrinsicContentSize)
                withMethod:@selector(PWSwizzled_intrinsicContentSize) error:nil];
}

#pragma mark - Hiding Master

static NSString* const PWHidingMasterViewKey = @"net.projectwizards.net.hidingMasterView";

- (PWView*)PWHidingMasterView
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey);
}

- (void)setPWHidingMasterView:(PWView*)master
{
    NSParameterAssert(master != self);

    PWView* previousMaster = self.PWHidingMasterView;
    if (master != previousMaster)
    {
        [previousMaster PWUnregisterHidingSlave:self];
        objc_setAssociatedObject(self, (__bridge const void*)PWHidingMasterViewKey, master, OBJC_ASSOCIATION_ASSIGN);
        [master PWRegisterHidingSlave:self];
    }
}

#pragma mark - Hiding Slaves

static NSString *const PWHidingSlavesKey = @"net.projectwizards.net.hidingSlaves";

- (NSHashTable *)PWHidingSlaves
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey);
}

- (void)PWRegisterHidingSlave:(id <PWViewHidingSlave>)slave
{
    NSParameterAssert(slave);
    NSHashTable *slaves = objc_getAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey);
    if (!slaves)
    {
		#if (__MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_8 || __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0)
			// the modern way
			slaves = [NSHashTable weakObjectsHashTable];
		#else
			// deprecated in 10.8
			slaves = [NSHashTable hashTableWithWeakObjects];
		#endif
        objc_setAssociatedObject(self, (__bridge const void*)PWHidingSlavesKey, slaves, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [slaves addObject:slave];
}

- (void)PWUnregisterHidingSlave:(id <PWViewHidingSlave>)slave
{
    NSParameterAssert(slave);
    [self.PWHidingSlaves removeObject:slave];
}

#pragma mark - Auto collapse

static NSString *const PWAutoCollapseKey = @"net.projectwizards.net.autoCollapse";

- (NSString *)PWAutoCollapse
{
    return objc_getAssociatedObject(self, (__bridge const void*)PWAutoCollapseKey);
}

- (void)setPWAutoCollapse:(NSString*)value
{
    objc_setAssociatedObject(self, (__bridge const void*)PWAutoCollapseKey, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - Instrinsic content size

- (PWSize)PWSwizzled_intrinsicContentSize
{
    return [self PWIntrinsicContentSizeIsBase:YES];
}

- (PWSize)PWIntrinsicContentSizeIsBase:(BOOL)isBase
{
    BOOL autocollapseWidth = NO;
    BOOL autocollapseHeight = NO;
    NSString *value = self.PWAutoCollapse;
    if (self.isHidden)
    {
        if (value)
        {
            autocollapseWidth  = ([value rangeOfString:@"width"].location != NSNotFound);
            autocollapseHeight = ([value rangeOfString:@"height"].location != NSNotFound);
        }
        else if (self.PWHidingMasterView != nil || self.PWHidingSlaves.count > 0)
        {
            autocollapseWidth = YES;
            autocollapseHeight = YES;
        }
    }

	#if TARGET_OS_IPHONE
		#define PWViewNoIntrinsicMetric UIViewNoIntrinsicMetric
	#else
		#define PWViewNoIntrinsicMetric NSViewNoInstrinsicMetric
	#endif
    PWSize size = self.PWSwizzled_intrinsicContentSize; // no recursion since methods are swizzled
    if (autocollapseWidth && (isBase || size.width != PWViewNoIntrinsicMetric))
    {
        size.width = 0.0;
    }
    if (autocollapseHeight && (isBase || size.height != PWViewNoIntrinsicMetric))
    {
        size.height = 0.0;
    }
    return size;
}

#pragma mark - Hiding

- (void)PWSwizzled_setHidden:(BOOL)hidden
{
    [self PWSwizzled_setHidden:hidden]; // no recursion since methods are swizzled
    for (id <PWViewHidingSlave> iSlave in self.PWHidingSlaves)
    {
        [iSlave setPWHidden:hidden];
    }
    if (self.PWHidingMasterView != nil || self.PWHidingSlaves.count > 0 || self.PWAutoCollapse != nil)
    {
        [self invalidateIntrinsicContentSize];
    }
}


#pragma mark - PWHidingSlave protocol

- (BOOL)isPWHidden
{
    return self.isHidden;
}

- (void)setPWHidden:(BOOL)PWHidden
{
    self.hidden = PWHidden;
}
@end

#pragma mark - Swizzling intrinsic content size in AppKit controls

#define SWIZZLE_CONTROL(ControlName) \
	@implementation ControlName (PWAutoLayout) \
	+ (void)load { \
		[self jr_swizzleMethod:@selector(intrinsicContentSize) withMethod:@selector(PWSwizzled_intrinsicContentSize) error:nil]; \
	} \
	- (PWSize)PWSwizzled_intrinsicContentSize { \
		return [self PWIntrinsicContentSizeIsBase:NO]; \
	} \
	@end

/*
 * TODO: Add any controls here that you want to use with this feature:
 */
#if TARGET_OS_IPHONE
/* Apparently, iOS doesn't need this done for controls because they seem
 * to share their implementation with their super class (UIView).
 * If we'd swizzle them here anyway, we'd run into endless recursions.
	SWIZZLE_CONTROL(UILabel)
	SWIZZLE_CONTROL(UIButton)
	SWIZZLE_CONTROL(UISwitch)
	SWIZZLE_CONTROL(UITextField)
	SWIZZLE_CONTROL(UITextView)
*/
#else
	SWIZZLE_CONTROL(NSButton)
	SWIZZLE_CONTROL(NSTextField)
	SWIZZLE_CONTROL(NSMatrix)
	SWIZZLE_CONTROL(NSSlider)
#endif
