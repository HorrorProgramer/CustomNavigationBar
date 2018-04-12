//
//  PJJViewController.m
//  CustomNavigationBar
//
//  Created by HorrorProgramer on 04/12/2018.
//  Copyright (c) 2018 HorrorProgramer. All rights reserved.
//

#import "PJJViewController.h"
#import "UIBarButtonItem+ZGCCreate.h"
#import "PJJ_TestViewController.h"

@interface PJJViewController ()

@end

@implementation PJJViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(rightBtnClick:) image:[UIImage imageNamed:@"my_icon_search"]];
}

- (void)rightBtnClick:(UIButton *)btn {
    PJJ_TestViewController *test = [[PJJ_TestViewController alloc] init];
    
    [self.navigationController pushViewController:test animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
