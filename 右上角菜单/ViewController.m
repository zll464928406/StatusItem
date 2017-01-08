//
//  ViewController.m
//  右上角菜单
//
//  Created by 张令林 on 2016/12/20.
//  Copyright © 2016年 personer. All rights reserved.
//

#import "ViewController.h"
#import "AXStatusItemPopup.h"
#import "Test.h"

@interface ViewController ()<AXStatusItemPopupDelegate>

@property (nonatomic,strong) NSStatusItem *statusItem;

@property (nonatomic, readwrite, strong) AXStatusItemPopup * statusItemPopup;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpUI];
}


#pragma mark 右上角菜单
- (void)setUpUI
{
//    NSStatusItem * item;
//    item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
//    [item setTitle:@"你好"];
//    
//    
//    NSImageView * statusImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 22, 22)];
//    statusImageView.image = [NSImage imageNamed:@"binder_cover_cunstructions1"];
//    [item setView:statusImageView];
//    [item setHighlightMode:YES];
    
    //系统类型
    /*
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setImage:[NSImage imageNamed:@"status_logo_yellow"]];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setAction:@selector(onStatusItemClicked:)];
    [self.statusItem setTarget:self];
     */
    
    //自定义类型
    NSViewController *controller = [[NSViewController alloc] initWithNibName:@"Test" bundle:nil];
    NSImage *image = [NSImage imageNamed:@"1"];
    NSImage *alternateImage = [NSImage imageNamed:@"1"];
    NSImage *disableImage = [NSImage imageNamed:@"1"];
    NSImage *reminderImage = [NSImage imageNamed:@"2"];
    self.statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:controller image:image alternateImage:alternateImage disableImage:disableImage reminderImage:reminderImage];
    self.statusItemPopup.delegate = self;
    
    //设置为yes,默认右上角的视图已经生成
    self.statusItemPopup.enable = YES;
}


#pragma mark- AXStatusItemPopupDelegate
- (void)statusItemPopupMouseClick:(AXStatusItemPopup*)statusItemPopup
{
    if (!statusItemPopup.enable)
    {//判断右上角的视图是否存在,也就是是否生成,可以理解为如果登录成功设置为yes,否则为no,然后弹出登录页面
        //弹出登录页面,登录成功以后设置为yes   statusItemPopup.enable = YES;
    }
}
- (void)statusItemPopupWillShow:(AXStatusItemPopup*)statusItemPopup
{
    //右上角的视图将要显示
}

- (void)statusItemPopupDidShow:(AXStatusItemPopup*)statusItemPopup
{
    //右上角的视图已经显示
}

- (void)statusItemPopupDidClose:(AXStatusItemPopup*)statusItemPopup
{
    //右上角的视图已经关闭
}


@end
