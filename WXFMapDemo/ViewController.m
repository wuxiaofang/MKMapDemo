//
//  ViewController.m
//  WXFMapDemo
//
//  Created by yongche_w on 16/3/23.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import "ViewController.h"
#import "WXFDragMapView.h"
@interface ViewController ()

@property (nonatomic, strong) WXFDragMapView* dragMapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dragMapView = [[WXFDragMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.dragMapView];
}

- (void)viewDidLayoutSubviews
{
    self.dragMapView.frame = self.view.bounds;
}


@end
