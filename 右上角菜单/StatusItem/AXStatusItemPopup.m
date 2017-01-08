//
//  StatusItemPopup.m
//  StatusItemPopup
//
//  Created by Alexander Schuch on 06/03/13.
//  Copyright (c) 2013 Alexander Schuch. All rights reserved.
//

#import "AXStatusItemPopup.h"
#import "NSWindow+canBecomeKeyWindow.h"
#import "NSString+Extension.h"
#import "NS(Attributed)String+Geometrics.h"
#import <Quartz/Quartz.h>

#define kMinViewWidth 22
#define kTextFieldWidth 30
#define kReminderViewWidth 11.5

//
// Private variables
//
@interface AXStatusItemPopup ()<NSPopoverDelegate>{
    NSViewController *_viewController;
    BOOL _active;
    BOOL _enable;
    BOOL _refresh;
    NSImageView *_imageView;
    NSImageView *_reminderImageView;
    NSStatusItem *_statusItem;
    NSPopover *_popover;
    NSArray *_refreshImages;
    NSTimer *_refreshTimer;
    id _popoverTransiencyMonitor;
    CAAnimationGroup *_reminderAnimation;
}
@end

///////////////////////////////////

//
// Implementation
//
@implementation AXStatusItemPopup

- (id)initWithViewController:(NSViewController *)controller
{
    return [self initWithViewController:controller image:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image
{
    return [self initWithViewController:controller image:image alternateImage:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage
{
    return [self initWithViewController:controller image:image alternateImage:alternateImage disableImage:nil reminderImage:nil];
}

- (id)initWithViewController:(NSViewController *)controller image:(NSImage *)image alternateImage:(NSImage *)alternateImage disableImage:(NSImage *)disableImage reminderImage:(NSImage*)reminderImage
{
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    CGFloat width = kMinViewWidth + kTextFieldWidth;
    
    self = [super initWithFrame:NSMakeRect(0, 0, width, height)];
    if (self) {
        _viewController = controller;
        
        if (!_popover) {
            _popover = [[NSPopover alloc] init];
            
            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_9) {
                [_popover setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];
            }
            _popover.delegate = self;
            _popover.contentViewController = _viewController;
        }
        
        self.image = image;
        self.alternateImage = alternateImage;
        self.disableImage = disableImage;
        
        _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, kMinViewWidth, height)];
        _imageView.imageFrameStyle = NSImageFrameNone;
        _imageView.imageAlignment = NSImageAlignCenter;
        [self addSubview:_imageView];
        
        self.textField = [[NSTextField alloc] initWithFrame:NSMakeRect(kMinViewWidth-4, 4, kTextFieldWidth, height-5)];
        [self.textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.textField setFont:[NSFont systemFontOfSize:14]];
        [self.textField setBezeled:NO];
        [self.textField setDrawsBackground:NO];
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
        [self.textField setTextColor:[NSColor blackColor]];
        [self.textField setAlignment:NSLeftTextAlignment];
        [self addSubview:self.textField];
        
        if (reminderImage) {
            
            _reminderImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(_imageView.bounds) - kReminderViewWidth-0.6, 2, kReminderViewWidth, kReminderViewWidth)];
            _reminderImageView.image = reminderImage;
            [_reminderImageView setHidden:YES];
            [_reminderImageView setWantsLayer:YES];
             [_reminderImageView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
            [_imageView addSubview:_reminderImageView];
            
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.2]];
            [opacityAnimation setToValue:[NSNumber numberWithFloat:0.6]];
            
            CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = [NSNumber numberWithDouble:1.2f];
            scaleAnimation.toValue = [NSNumber numberWithDouble:1.0f];
            
            _reminderAnimation = [CAAnimationGroup animation];
            _reminderAnimation.animations = [NSArray arrayWithObjects:opacityAnimation,scaleAnimation, nil];
            
            [_reminderAnimation setDuration:0.5f];
            [_reminderAnimation setTimingFunction:[CAMediaTimingFunction
                                                   functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [_reminderAnimation setAutoreverses:YES];
            [_reminderAnimation setRepeatCount:10];
        }
        
        self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        self.statusItem.view = self;
        
        _enable = NO;
        _active = NO;
        _animated = NO;
        
        windowToOverride = self.window;
    }
    return self;
}


////////////////////////////////////
#pragma mark - Drawing
////////////////////////////////////

- (void)drawRect:(NSRect)dirtyRect
{
    // set view background color
    if (_active) {
        [[NSColor selectedMenuItemColor] setFill];
    } else {
        [[NSColor clearColor] setFill];
    }
    NSRectFill(dirtyRect);
    
    // set image
    //NSImage *image = (_active ? _alternateImage : _image);
    //_imageView.image = image;
    
    if (!_refresh) {
        if (!_enable) {
            _imageView.image = self.disableImage;
        }
        else if (_active) {
            _imageView.image = self.alternateImage;
        }
        else {
            _imageView.image = self.image;
        }
    }
    
}

////////////////////////////////////
#pragma mark - Position / Size
////////////////////////////////////

- (void)setContentSize:(NSSize)size
{
    _popover.contentSize = size;
}

////////////////////////////////////
#pragma mark - Mouse Actions
////////////////////////////////////

- (void)mouseDown:(NSEvent *)theEvent
{
    if (_enable && !_refresh) {
        if (_popover.isShown) {
            [self hidePopover];
        } else {
            [self showPopover];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(statusItemPopupMouseClick:)]) {
        [self.delegate statusItemPopupMouseClick:self];
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if (_enable && !_refresh) {
        if (_popover.isShown) {
            [self hidePopover];
        } else {
            [self showPopover];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(statusItemPopupMouseClick:)]) {
        [self.delegate statusItemPopupMouseClick:self];
    }
}

////////////////////////////////////
#pragma mark - Setter
////////////////////////////////////

- (void)setActive:(BOOL)active
{
    _active = active;
    [self setNeedsDisplay:YES];
}

- (void)setEnable:(BOOL)enable
{
    _enable = enable;
    
    if (!enable) {
        [self hidePopover];
        [_reminderImageView setHidden:YES];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage *)image
{
    _image = image;
    [self updateViewFrame];
}

- (void)setAlternateImage:(NSImage *)image
{
    _alternateImage = image;
    if (!image && _image) {
        _alternateImage = _image;
    }
    [self updateViewFrame];
}

- (void)setDisableImage:(NSImage *)disableImage
{
    _disableImage = disableImage;
     [self updateViewFrame];
}

- (void)startReminder
{
    if (self.enable) {
        [_reminderImageView setHidden:NO];
        //[_reminderImageView.layer addAnimation:_reminderAnimation forKey:@"opacity"];
    }
    
}

- (void)stopReminder
{
    //[_reminderImageView.layer removeAnimationForKey:@"opacity"];
    [_reminderImageView.animator setHidden:YES];
    
}
////////////////////////////////////
#pragma mark - Helper
////////////////////////////////////

- (void)updateViewFrame
{
    CGFloat width = MAX(MAX(kMinViewWidth, self.alternateImage.size.width), self.image.size.width);
    CGFloat height = [NSStatusBar systemStatusBar].thickness;
    
    NSRect frame = NSMakeRect(0, 0, width, height);
    self.frame = frame;
    _imageView.frame = frame;
    
    [self setNeedsDisplay:YES];
}

#pragma mark- NSPopoverDelegate
- (void)popoverDidClose:(NSNotification *)notification;
{
    if ([self.delegate respondsToSelector:@selector(statusItemPopupDidClose:)]) {
        [self.delegate statusItemPopupDidClose:self];
    }

}

- (void)popoverWillShow:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(statusItemPopupWillShow:)]) {
        [self.delegate statusItemPopupWillShow:self];
    }
}

- (void)popoverDidShow:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(statusItemPopupDidShow:)]) {
        [self.delegate statusItemPopupDidShow:self];
    }
}

////////////////////////////////////
#pragma mark - Show / Hide Popover
////////////////////////////////////

- (void)showPopover
{
    if (_enable) {
        [self showPopoverAnimated:_animated];
    }
}

- (void)showPopoverAnimated:(BOOL)animated
{
    self.active = YES;
    
    if (!_popover.isShown) {
        _popover.animates = animated;
        shouldBecomeKeyWindow = YES;
        [_popover showRelativeToRect:self.frame ofView:self preferredEdge:NSMinYEdge];
        
        [self.window makeKeyWindow];
        [self.window becomeFirstResponder];
        
        _popoverTransiencyMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask|NSRightMouseDownMask handler:^(NSEvent* event) {
            [self hidePopover];
        }];
    }
}

- (void)hidePopover
{
    self.active = NO;
    
    if (_popover && _popover.isShown) {
        [_popover close];
        shouldBecomeKeyWindow = NO;

		if (_popoverTransiencyMonitor) {
            [NSEvent removeMonitor:_popoverTransiencyMonitor];
            _popoverTransiencyMonitor = nil;
        }
    }
}

- (void)startRefreshWithImages:(NSArray*)images
{
    _refreshImages = images;
    _refresh = YES;
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:0.200 target:self selector:@selector(refreshImages:) userInfo:nil repeats:YES];
}

- (void)stopRefresh
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    
    _refresh = NO;
}

- (void)updateText:(NSString*)text andImage:(NSImage*)image
{
    _image = image;
    _imageView.image = image;
    
    if (text && text.length > 0) {
        
        CGFloat textLength = [text sizeForWidth:FLT_MAX height:FLT_MAX font:self.textField.font].width;
        
        NSRect textFieldFrame = self.textField.frame;
        [self.textField setFrame:NSMakeRect(NSMinX(textFieldFrame), NSMinY(textFieldFrame), textLength, NSHeight(textFieldFrame))];
        
        NSRect myFrame = self.frame;
        [self setFrame:NSMakeRect(NSMinX(myFrame), NSMinY(myFrame), kMinViewWidth + textLength, NSHeight(myFrame))];
        self.textField.stringValue = text;
    
        [self.statusItem setLength:kMinViewWidth-8 + textLength ];
    }
    else {
        [self.statusItem setLength:kMinViewWidth];
        self.textField.stringValue = @"";
    }
}

- (void)updateImage:(NSImage*)image
{
    _image = image;
    _imageView.image = image;
    
}
- (void)refreshImages:(NSTimer*)timer
{
    static int index = 0;
	index ++;
	if (index>=12) index = 0;
	
	[_imageView setImage:_refreshImages[index]];
}
@end

