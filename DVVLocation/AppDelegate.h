//
//  AppDelegate.h
//  DVVLocation
//
//  Created by 大威 on 2016/10/31.
//  Copyright © 2016年 devdawei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BMKMapManager;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) BMKMapManager *mapManager;

@end

