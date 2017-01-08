//
//  NSWindow+canBecomeKeyWindow.m
//  Demo
//
//  Created by Raymond Xu on 7/21/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

#import "NSWindow+canBecomeKeyWindow.h"
#import <objc/runtime.h>

BOOL shouldBecomeKeyWindow = NO;
NSWindow* windowToOverride = nil;

@implementation NSWindow (canBecomeKeyWindow)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)canBecomeKeyWindow
{
    return YES;
}
#pragma clang diagnostic pop
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (BOOL)popoverCanBecomeKeyWindow
{
    if (self == windowToOverride )
    {
        return shouldBecomeKeyWindow;
        
    } else
    {
        return [self popoverCanBecomeKeyWindow];
    }
}

+ (void)load
{
    method_exchangeImplementations(
                                   class_getInstanceMethod(self, @selector(canBecomeKeyWindow)),
                                   class_getInstanceMethod(self, @selector(popoverCanBecomeKeyWindow)));
}
#pragma clang diagnostic pop
@end
