//
//  TouchIDManager.m
//  TouchIDdemo
//
//  Created by srj on 2018/1/31.
//  Copyright © 2018年 anniu. All rights reserved.
//

#import "TouchIDManager.h"
//引入LocalAuthentication.framework
#import <LocalAuthentication/LocalAuthentication.h>

@implementation TouchIDManager
+ (instancetype)sharedManager {
    static TouchIDManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TouchIDManager alloc] init];
    });
    return instance;
}
-(void)showTouchIDWithDescribe:(NSString *)desc viewController:(UIViewController *)vc block:(StateBlock)block
{
    LAContext *context = [[LAContext alloc]init];
    context.localizedFallbackTitle = desc;
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:desc == nil ? @"通过Home键验证已有指纹":desc reply:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"TouchID 验证成功");
                    block(TDTouchIDStateSuccess,error);
                });
            }else if(error){
                [self error:error viewController:vc block:block];
            }
        }];
    }else {
        [self error:error viewController:vc block:block];
    }
}

- (void)error:(NSError *)error viewController:vc block:(StateBlock)block;
{
    switch (error.code) {
        case LAErrorAuthenticationFailed:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 验证失败");
//                block(TDTouchIDStateFail,error);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"TouchID 验证失败 请确保本机系统中 [设置-Touch ID与密码] 已添加指纹" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:okAction];
                [vc presentViewController:alert animated:YES completion:nil];
            });
            break;
        }
        case LAErrorUserCancel:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 被用户手动取消");
                block(TDTouchIDStateUserCancel,error);
            });
        }
            break;
        case LAErrorUserFallback:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"用户不使用TouchID,选择手动输入密码");
                block(TDTouchIDStateInputPassword,error);
            });
        }
            break;
        case LAErrorSystemCancel:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
                block(TDTouchIDStateSystemCancel,error);
            });
        }
            break;
        case LAErrorPasscodeNotSet:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 无法启动,因为用户没有设置密码");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请确保本机系统中用户已设置密码并且开启，否则Touch ID无法启动" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:okAction];
                [vc presentViewController:alert animated:YES completion:nil];
            });
        }
            break;
        case LAErrorTouchIDNotEnrolled:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 无法启动,因为用户没有设置TouchID");
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请确保本机系统中 [设置-Touch ID与密码] 已添加指纹，否则Touch ID无法启动" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:okAction];
                [vc presentViewController:alert animated:YES completion:nil];
            });
        }
            break;
        case LAErrorTouchIDNotAvailable:{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请确保本机系统中[设置-Touch ID与密码] 已添加指纹或者关闭本机屏幕再重新操作" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:okAction];
                [vc presentViewController:alert animated:YES completion:nil];
            });
        }
            break;
        case LAErrorTouchIDLockout:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
//                block(TDTouchIDStateTouchIDLockout,error);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请确保本机系统中[设置-Touch ID与密码] 已添加指纹或者关闭本机屏幕再重新操作" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                [alert addAction:okAction];
                [vc presentViewController:alert animated:YES completion:nil];
            });
        }
            break;
        case LAErrorAppCancel:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
                block(TDTouchIDStateAppCancel,error);
            });
        }
            break;
        case LAErrorInvalidContext:{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
                block(TDTouchIDStateInvalidContext,error);
            });
        }
            break;
        default:
            break;
    }
}
@end
