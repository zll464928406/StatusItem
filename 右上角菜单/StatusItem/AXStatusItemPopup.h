//
//  StatusItemPopup.h
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AXStatusItemPopup;

@protocol AXStatusItemPopupDelegate <NSObject>

@optional
- (void)statusItemPopupMouseClick:(AXStatusItemPopup*)statusItemPopup;
- (void)statusItemPopupWillShow:(AXStatusItemPopup*)statusItemPopup;
- (void)statusItemPopupDidShow:(AXStatusItemPopup*)statusItemPopup;
- (void)statusItemPopupDidClose:(AXStatusItemPopup*)statusItemPopup;
@end

@interface AXStatusItemPopup : NSView

// properties
@property(assign, nonatomic, getter=isActive) BOOL active;
@property(assign, nonatomic, getter=isEnable) BOOL enable;
@property(assign, nonatomic) BOOL animated;
@property(strong, nonatomic) NSImage *image;
@property(strong, nonatomic) NSImage *alternateImage;
@property(strong, nonatomic) NSImage *disableImage;
@property(strong, nonatomic) NSStatusItem *statusItem;
@property(strong, nonatomic) NSTextField *textField;
@property(weak) id<AXStatusItemPopupDelegate> delegate;


// init
- (id)initWithViewController:(NSViewController *)controller;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage;
- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage disableImage:(NSImage *)disableImage reminderImage:(NSImage*)reminderImage;


// show / hide popover
- (void)showPopover;
- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopover;
- (void)startReminder;
- (void)stopReminder;
- (void)startRefreshWithImages:(NSArray*)images;
- (void)stopRefresh;
- (void)updateText:(NSString*)text andImage:(NSImage*)image;
- (void)updateImage:(NSImage*)image;

// view size
- (void)setContentSize:(NSSize)size;

@end
