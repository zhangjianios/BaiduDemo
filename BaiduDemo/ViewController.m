//
//  ViewController.m
//  BaiduDemo
//
//  Created by 张建 on 17/5/9.
//  Copyright © 2017年 zhangjian. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    //地图
    BMKMapView* _mapView;
    //定位
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_geocodesearch; //地理编码主类，用来查询、返回结果信息
    BMKPointAnnotation *_pointAnnotation;
    CLLocationCoordinate2D coord;
    
    NSString *address;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //添加地图
    [self addBaiduMap];
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    
//    _geocodesearch.delegate = self;

    //开始定位
    [self startLocation];
    
}

- (void)addBaiduMap{
    
    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _mapView.mapType = BMKMapTypeStandard;//设置地图为空白类型
    _mapView.showsUserLocation = YES;//是否显示定位图层（即我的位置的小圆点）
    [_mapView setZoomLevel:19.0];
//    _mapView.userTrackingMode = BMKUserTrackingModeFollow;
    [self.view addSubview:_mapView];
    
    //去除百度地图定位后的蓝色圆圈和定位蓝点(精度圈)
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isAccuracyCircleShow = false;//精度圈是否显示
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    displayParam.locationViewImgName= @"icon";//定位图标名称 去除蓝色的圈
    [_mapView updateLocationViewWithParam:displayParam];
}

- (void)startLocation{
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
//    _locService.delegate = self;
//    _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//    _locService.distanceFilter = 100.f;
    //启动LocationService
    [_locService startUserLocationService];
    
    //解决定位用户的位置,进来直接显示天安门
//    BMKCoordinateRegion region;
//    region = BMKCoordinateRegionMake(coord, BMKCoordinateSpanMake(0.02f, 0.02f));
//    BMKCoordinateRegion adjustRegion = [_mapView regionThatFits:region];
//    [_mapView setRegion:adjustRegion animated:YES];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    //NSLog(@"heading is %@",userLocation.heading);
//    [_mapView updateLocationData:userLocation];
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"获取坐标成功");
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
//    //更新地图上的位置
//    [_mapView updateLocationData:userLocation];
    if (userLocation.location != nil) {
        
//        [_locService stopUserLocationService];
        
        //添加当前位置的标注
        CLLocationCoordinate2D pt;
        pt = userLocation.location.coordinate;
        pt.latitude = userLocation.location.coordinate.latitude;
        pt.longitude = userLocation.location.coordinate.longitude;

        _pointAnnotation = [[BMKPointAnnotation alloc] init];
        _pointAnnotation.coordinate = pt;
        
        [_mapView setCenterCoordinate:pt animated:true];
        [_mapView addAnnotation:_pointAnnotation];

        //反编码地理位置
        BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeocodeSearchOption.reverseGeoPoint = pt;
        if ([_geocodesearch reverseGeoCode:reverseGeocodeSearchOption]) {
            [_locService stopUserLocationService];
        }

    }
    
//    //表示范围的结构体
//    BMKCoordinateRegion region;
//    region.center.latitude = userLocation.location.coordinate.latitude;
//    region.center.longitude = userLocation.location.coordinate.longitude;
    //    经度范围（设置为0.1表示显示范围为0.2的纬度范围）
    
    
//    _mapView.centerCoordinate = userLocation.location.coordinate; //更新当前位置到地图中间
//    
//    //地理反编码
//    
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    
//    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
//    
//    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
//    
//    if(flag){
//        
//        NSLog(@"反geo检索发送成功");
////        _mapView.region = region;
//        [_locService stopUserLocationService];
//        
//    }else{
//        
//        NSLog(@"反geo检索发送失败");
//        
//    }
//    _mapView.region = region;
    
 
//    CLLocationCoordinate2D pt=(CLLocationCoordinate2D){0,0};
//    pt=(CLLocationCoordinate2D){coord.latitude,coord.longitude};
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_mapView removeOverlays:_mapView.overlays];
//        [_mapView setCenterCoordinate:coord animated:true];
//        [_mapView addAnnotation:_pointAnnotation];
//
//    });
    /*
    //方法一:
    //创建地理编码对象
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //创建位置
    CLLocation *location=[[CLLocation alloc]initWithLatitude:coord.latitude longitude:coord.longitude];
    
    //反地理编码
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //判断是否有错误或者placemarks是否为空
        if (error !=nil || placemarks.count==0) {
            NSLog(@"%@",error);
            return ;
        }
        for (CLPlacemark *placemark in placemarks) {
            //赋值详细地址
            NSLog(@"%@",placemark.name);
            _pointAnnotation.title = placemark.name;
        }
    }];
    */
    /*
     //    //表示范围的结构体
     //    BMKCoordinateRegion region;
     //    region.center.latitude = userLocation.location.coordinate.latitude;
     //    region.center.longitude = userLocation.location.coordinate.longitude;
     ////    经度范围（设置为0.1表示显示范围为0.2的纬度范围）
     //    region.span.latitudeDelta = 0.2;
     //    region.span.longitudeDelta = 0.2;
     //    if (_mapView) {
     //        _mapView.region = region;
     //    }
     //    [_mapView setZoomLevel:19.0];
     
     //    [_locService stopUserLocationService];//定位完成停止位置更新
     */
}



#pragma mark -------------地理反编码的delegate---------------

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    
    NSLog(@"address:%@----%@-----%@",result.addressDetail, result.address,result.sematicDescription);
    
    if (error == 0) {
        [_locService stopUserLocationService];
        address = result.sematicDescription;
        _pointAnnotation.title = result.address;
        _pointAnnotation.subtitle = address;
    }else{
        NSLog(@"address:定位失败+++++");
    }
    
    //addressDetail:     层次化地址信息
    
    //address:    地址名称
    
    //businessCircle:  商圈名称
    
    // location:  地址坐标
    
    //  poiList:   地址周边POI信息，成员类型为BMKPoiInfo
    
//    if (error==0) {
//        BMKPointAnnotation *item=[[BMKPointAnnotation alloc] init];
//        item.coordinate=result.geoPt;//地理坐标
//        item.title=result.strAddr;//地理名称
//        [_mapView addAnnotation:item];
//        _mapView.centerCoordinate=result.geoPt;
//        
//        self.lalAddress.text=[result.strAddr stringByReplacingOccurrencesOfString:@"-" withString:@""];
//        if (![self.lalAddress.text isEqualToString:@""]) {
//            strProvince=result.addressComponent.province;//省份
//            strCity=result.addressComponent.city;//城市
//            strDistrict=result.addressComponent.district;//地区
//        }
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
