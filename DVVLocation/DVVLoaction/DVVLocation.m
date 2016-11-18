//
//  DVVLocation.m
//  DVVLocation <https://github.com/devdawei/DVVLocation.git>
//
//  Created by 大威 on 2016/10/31.
//  Copyright © 2016年 devdawei. All rights reserved.
//

#import "DVVLocation.h"
#import <DVVAlertView/DVVAlertView.h>

@interface DVVLocation () <BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKLocationService *locationService;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;

@property (nonatomic, copy) DVVLocationSuccessBlock locationSuccess;
@property (nonatomic, copy) DVVLocationErrorBlock locationError;

@property (nonatomic, copy) DVVLocationReverseGeoCodeSuccessBlock addressSuccess;
@property (nonatomic, copy) DVVLocationReverseGeoCodeErrorBlock addressError;

@property (nonatomic, copy) DVVLocationGeoCodeSuccessBlock geoCodeSuccess;
@property (nonatomic, copy) DVVLocationGeoCodeErrorBlock geoCodeError;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) BOOL onlyGetLocation;

- (void)setLocationSuccessBlock:(DVVLocationSuccessBlock)handle;
- (void)setLocationErrorBlock:(DVVLocationErrorBlock)handle;

- (void)setReverseGeoCodeSuccessBlock:(DVVLocationReverseGeoCodeSuccessBlock)handle;
- (void)setReverseGeoCodeErrorBlock:(DVVLocationReverseGeoCodeErrorBlock)handle;

- (void)setGeoCodeSuccessBlock:(DVVLocationGeoCodeSuccessBlock)handle;
- (void)setGeoCodeErrorBlock:(DVVLocationGeoCodeErrorBlock)handle;

- (void)emptyLocationBlock;
- (void)emptyReverseGeoCodeBlock;
- (void)emptyGeoCodeBlock;

- (void)startLocation;

- (BOOL)geoCodeWithCity:(NSString *)city address:(NSString *)address;

@end

@implementation DVVLocation

+ (instancetype)sharedLoaction
{
    static DVVLocation *location = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        location = [DVVLocation new];
    });
    return location;
}

- (void)startLocation
{
    if (kCLAuthorizationStatusDenied == [CLLocationManager authorizationStatus])
    {
        // 用户拒绝App使用
        [DVVAlertView showAlertWithTitle:@"提示" message:@"使用此功能需要您在设置中开启定位" buttonTitles:@[ @"知道了", @"去设置" ] completion:^(NSUInteger idx) {
            
            if (1 == idx) {
                // 打开设置面板
                [self goAppSet];
            }
            
        }];
        
        return ;
    }
    
    self.locationService.delegate = self;
    self.geoCodeSearch.delegate = self;
    
    [_locationService startUserLocationService];
}

+ (void)getLocation:(DVVLocationSuccessBlock)success
              error:(DVVLocationErrorBlock)error
{
    DVVLocation *location = [DVVLocation sharedLoaction];
    
    location.onlyGetLocation = YES;
    
    [location setLocationSuccessBlock:success];
    [location setLocationErrorBlock:error];
    
    [location emptyReverseGeoCodeBlock];
    [location emptyGeoCodeBlock];
    
    [location startLocation];
}

+ (void)reverseGeoCode:(DVVLocationReverseGeoCodeSuccessBlock)success
                 error:(DVVLocationReverseGeoCodeErrorBlock)error
{
    DVVLocation *location = [DVVLocation sharedLoaction];
    
    location.onlyGetLocation = NO;
    
    [location setReverseGeoCodeSuccessBlock:success];
    [location setReverseGeoCodeErrorBlock:error];
    
    [location emptyLocationBlock];
    [location emptyGeoCodeBlock];
    
    [location startLocation];
}

+ (void)geoCodeWithCity:(NSString *)city address:(NSString *)address success:(DVVLocationGeoCodeSuccessBlock)success error:(DVVLocationGeoCodeErrorBlock)error
{
    DVVLocation *location = [DVVLocation sharedLoaction];
    
    [location setGeoCodeSuccessBlock:success];
    [location setGeoCodeErrorBlock:error];
    
    [location emptyLocationBlock];
    [location emptyReverseGeoCodeBlock];
    
    [location geoCodeWithCity:city address:address];
}

- (void)emptyLocationBlock
{
    _locationSuccess = nil;
    _locationError = nil;
}
- (void)emptyReverseGeoCodeBlock
{
    _addressSuccess = nil;
    _addressError = nil;
}
- (void)emptyGeoCodeBlock
{
    _geoCodeSuccess = nil;
    _geoCodeError = nil;
}

#pragma mark - 位置坐标更新成功
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
//    NSLog(@"latitude === %lf   longitude === %lf", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    _coordinate = userLocation.location.coordinate;
    
    if (_locationSuccess)
    {
        _locationSuccess(userLocation,
                         _coordinate.latitude,
                         _coordinate.longitude);
    }
    if (_onlyGetLocation)
    {
        [self emptyLocationService];
        return ;
    }
    
    // 反地理编码，获取城市名
    [self reverseGeoCodeWithLatitude:_coordinate.latitude
                           longitude:_coordinate.longitude];
}

#pragma mark - 位置坐标更新失败
- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self emptyLocationService];
    if (_onlyGetLocation)
    {
        if (_locationError)
        {
            _locationError();
        }
    }
    else
    {
        if (_addressError)
        {
            _addressError();
        }
    }
}

#pragma mark - 反地理编码
- (BOOL)reverseGeoCodeWithLatitude:(double)latitude
                         longitude:(double)longitude
{
    CLLocationCoordinate2D point = (CLLocationCoordinate2D){ latitude, longitude };
    BMKReverseGeoCodeOption *reverseGeocodeOption = [BMKReverseGeoCodeOption new];
    reverseGeocodeOption.reverseGeoPoint = point;
    // 发起反向地理编码
    self.geoCodeSearch.delegate = self;
    BOOL flage = [self.geoCodeSearch reverseGeoCode:reverseGeocodeOption];
    if (flage)
    {
//        NSLog(@"反geo检索发送成功");
        return YES;
    }
    else
    {
//        NSLog(@"反geo检索发送失败");
        [self emptyLocationService];
        if (_addressError) _addressError();
        return NO;
    }
}

#pragma mark 反地理编码回调
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
//        NSLog(@"%@", result);
        BMKAddressComponent *addressComponent = result.addressDetail;
        // 城市名
//        NSLog(@"city === %@",addressComponent.city);
        // 详细地址
//        NSLog(@"address === %@", result.address);
        
        if (_addressSuccess)
        {
            _addressSuccess(result,
                            _coordinate,
                            addressComponent.city,
                            result.address);
        }
    }
    else
    {
//        NSLog(@"抱歉，未找到结果");
        if (_addressError) _addressError();
    }
    [self emptyLocationService];
}

#pragma mark - 正地理编码
- (BOOL)geoCodeWithCity:(NSString *)city address:(NSString *)address
{
    BMKGeoCodeSearchOption *geoCodeSearchOption = [BMKGeoCodeSearchOption new];
    geoCodeSearchOption.city = city;
    geoCodeSearchOption.address = address;
//    geoCodeSearchOption.city= @"北京市";
//    geoCodeSearchOption.address = @"海淀区上地10街10号";
    self.geoCodeSearch.delegate = self;
    BOOL flage = [self.geoCodeSearch geoCode:geoCodeSearchOption];
    if(flage)
    {
//        NSLog(@"geo检索发送成功");
        return YES;
    }
    else
    {
        [self emptyLocationService];
        if (_geoCodeError) {
            _geoCodeError();
        }
//        NSLog(@"geo检索发送失败");
        return NO;
    }
}

#pragma mark 正地理编码回调
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR)
    {
//        NSLog(@"result.location.latitude===%f, result.location.longitude===%f",result.location.latitude,result.location.longitude);
        
        _coordinate = result.location;
        if (_geoCodeSuccess)
        {
            _geoCodeSuccess(result,
                            result.location,
                            result.location.latitude,
                            result.location.longitude);
        }
    }
    else
    {
//        NSLog(@"抱歉，未找到结果");
        if (_geoCodeError) _geoCodeError();
    }
    [self emptyLocationService];
}

#pragma mark - Empty location service

- (void)emptyLocationService
{
    // 停止位置更新服务
    if (_locationService)
    {
        [_locationService stopUserLocationService];
        _locationService.delegate = nil;
        _geoCodeSearch.delegate = nil;
    }
    
}

#pragma mark -

- (void)goAppSet
{
    // 打开应用设置面板
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([app canOpenURL:url])
    {
        if ([UIDevice currentDevice].systemName.floatValue >= 10.0)
        {
            [app openURL:url options:@{} completionHandler:nil];
        }
        else
        {
            [app openURL:url];
        }
    }
}

#pragma mark - Set block

- (void)setLocationSuccessBlock:(DVVLocationSuccessBlock)handle
{
    _locationSuccess = handle;
}
- (void)setLocationErrorBlock:(DVVLocationErrorBlock)handle
{
    _locationError = handle;
}
- (void)setReverseGeoCodeSuccessBlock:(DVVLocationReverseGeoCodeSuccessBlock)handle
{
    _addressSuccess = handle;
}
- (void)setReverseGeoCodeErrorBlock:(DVVLocationReverseGeoCodeErrorBlock)handle
{
    _addressError = handle;
}
- (void)setGeoCodeSuccessBlock:(DVVLocationGeoCodeSuccessBlock)handle
{
    _geoCodeSuccess = handle;
}
- (void)setGeoCodeErrorBlock:(DVVLocationGeoCodeErrorBlock)handle
{
    _geoCodeError = handle;
}

#pragma mark - Lazy load

- (BMKLocationService *)locationService {
    if (!_locationService) {
        _locationService = [BMKLocationService new];
        // 定位精度
        _locationService.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        // 设定定位的最小更新距离
        _locationService.distanceFilter = 10000.f;
        _locationService.delegate = self;
    }
    return _locationService;
}

- (BMKGeoCodeSearch *)geoCodeSearch {
    if (!_geoCodeSearch) {
        _geoCodeSearch = [BMKGeoCodeSearch new];
        _geoCodeSearch.delegate = self;
    }
    return _geoCodeSearch;
}

@end
