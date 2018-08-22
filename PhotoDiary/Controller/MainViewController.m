//
//  ViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 21/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSInteger tag = item.tag;
    NSLog(@"%@ %ld", @"Clicked item in tab bar: ", tag);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
