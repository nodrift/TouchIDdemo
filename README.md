# TouchIDdemo

适用于ios8以上
 [[TouchIDManager sharedManager] showTouchIDWithDescribe:nil viewController:self block:^(TouchIDState state, NSError *error) {
        if(state == TDTouchIDStateSuccess){
            //成功
        }else if (state == TDTouchIDStateInputPassword){
            //使用密码 主线程
        }
        //其他alert显示 或者 cancel不作为
    }];
