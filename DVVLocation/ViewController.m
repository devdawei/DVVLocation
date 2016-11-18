//
//  ViewController.m
//  DVVLocation
//
//  Created by 大威 on 2016/10/31.
//  Copyright © 2016年 devdawei. All rights reserved.
//

#import "ViewController.h"
#import "DVVLocation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)getLocationButtonAction:(UIButton *)sender
{
    [DVVLocation getLocation:^(BMKUserLocation *userLocation, double latitude, double longitude) {
        
        NSLog(@"\n\n获取经纬度");
        NSLog(@"latitude: %f  longitude: %f", latitude, longitude);
        
    } error:^{
        NSLog(@"获取经纬度失败");
    }];
}
- (IBAction)reverseGeoCodeButtonAction:(UIButton *)sender
{
    [DVVLocation reverseGeoCode:^(BMKReverseGeoCodeResult *result, CLLocationCoordinate2D coordinate, NSString *city, NSString *address) {
        
        NSLog(@"\n\n反地理编码");
        NSLog(@"coordinate.latitude: %f  coordinate.longitude: %f", coordinate.latitude, coordinate.longitude);
        NSLog(@"city: %@  address: %@", city, address);
        
    } error:^{
        NSLog(@"反地理编码失败");
    }];
}
- (IBAction)geoCodeButtonAction:(UIButton *)sender
{
    [DVVLocation geoCodeWithCity:@"北京" address:@"北京市海淀区中关村" success:^(BMKGeoCodeResult *result, CLLocationCoordinate2D coordinate, double latitude, double longitude) {
        
        NSLog(@"\n\n正地理编码");
        NSLog(@"latitude: %f  longitude: %f", latitude, longitude);
        
    } error:^{
        NSLog(@"正地理编码失败");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
