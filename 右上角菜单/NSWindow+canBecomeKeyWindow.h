//
//  NSWindow+canBecomeKeyWindow.h
//  Demo
//
//  Created by Raymond Xu on 7/21/14.
//  Copyright (c) 2014 Alexander Schuch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern BOOL shouldBecomeKeyWindow;
extern NSWindow* windowToOverride;

@interface NSWindow (canBecomeKeyWindow)

@end
