//
//  ViewController.m
//  TouchIDdemo
//
//  Created by srj on 2018/1/31.
//  Copyright © 2018年 anniu. All rights reserved.
//

#import "ViewController.h"
#import "TouchIDManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)loginBtnPressed:(id)sender {
    [[TouchIDManager sharedManager] showTouchIDWithDescribe:nil viewController:self block:^(TouchIDState state, NSError *error) {
        if(state == TDTouchIDStateSuccess){
            //成功
        }else if (state == TDTouchIDStateInputPassword){
            //使用密码
            
        }
    }];
}

@end
