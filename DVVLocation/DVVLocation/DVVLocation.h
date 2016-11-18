//
//  DVVLocation.h
//  DVVLocation <https://github.com/devdawei/DVVLocation.git>
//
//  Created by 大威 on 2016/10/31.
//  Copyright © 2016年 devdawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

// 位置坐标
typedef void(^DVVLocationSuccessBlock)(
BMKUserLocation *userLocation,
double latitude,
double longitude);
typedef void(^DVVLocationErrorBlock)();

// 反地理编码
typedef void(^DVVLocationReverseGeoCodeSuccessBlock)(
BMKReverseGeoCodeResult *result,
CLLocationCoordinate2D coordinate,
NSString *city,
NSString *address);
typedef void(^DVVLocationReverseGeoCodeErrorBlock)();

// 正地理编码
typedef void(^DVVLocationGeoCodeSuccessBlock)(
BMKGeoCodeResult *result,
CLLocationCoordinate2D coordinate,
double latitude,
double longitude);
typedef void(^DVVLocationGeoCodeErrorBlock)();

@interface DVVLocation : NSObject

/**
 初始化方法
 
 @return instancetype
 */
+ (instancetype)sharedLoaction;

/**
 *  获取经纬度
 *
 *  @param success 成功的回调Block
 *  @param error   失败的回调Block
 */
+ (void)getLocation:(DVVLocationSuccessBlock)success
              error:(DVVLocationErrorBlock)error;

/**
 *  反地理编码
 *
 *  @param success 成功的回调Block
 *  @param error   失败的回调Block
 */
+ (void)reverseGeoCode:(DVVLocationReverseGeoCodeSuccessBlock)success
                 error:(DVVLocationReverseGeoCodeErrorBlock)error;

/**
 *  正地理编码
 *
 *  @param city    城市名
 *  @param address 详细地址
 *  @param success 成功的回调Block
 *  @param error   失败的回调Block
 */
+ (void)geoCodeWithCity:(NSString *)city
                address:(NSString *)address
                success:(DVVLocationGeoCodeSuccessBlock)success
                  error:(DVVLocationGeoCodeErrorBlock)error;

@end
