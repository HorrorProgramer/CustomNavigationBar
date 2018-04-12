//
//  PJJ_TestViewController.m
//  CustomNavigationBar_Example
//
//  Created by mac on 2018/4/12.
//  Copyright © 2018年 HorrorProgramer. All rights reserved.
//

#import "PJJ_TestViewController.h"
#import "UIBarButtonItem+ZGCCreate.h"

@interface PJJ_TestViewController ()

@end

@implementation PJJ_TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(leftBtnClick:) image:[UIImage imageNamed:@"offer_nav_return"]];
}

- (void)leftBtnClick:(UIButton *)btn {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
