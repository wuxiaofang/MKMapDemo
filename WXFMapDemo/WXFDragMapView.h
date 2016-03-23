//
//  WXFDragMapView.h
//  WXFMapDemo
//
//  Created by yongche_w on 16/3/23.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class WXFDragMapView;
//地图缩放的等级
//
typedef enum {
    WXFMKMapZoomLevelOne = 1,        //0.001484    0.001006
    WXFMKMapZoomLevelTwo ,           //0.002968    0.002012
    WXFMKMapZoomLevelThree ,         //0.005936    0.004023
    WXFMKMapZoomLevelFour,           //0.011872    0.008047
    WXFMKMapZoomLevelFive,           //0.023743    0.016093
    WXFMKMapZoomLevelSix ,           //0.047484    0.032187
    WXFMKMapZoomLevelSeven,          //0.094961    0.064373
    WXFMKMapZoomLevelEight,          //0.189895    0.128746
    WXFMKMapZoomLevelNine,           //0.379681    0.257492
    WXFMKMapZoomLevelTen,            //0.758927    0.514984
    WXFMKMapZoomLevelEleven,         //1.516251    1.029968
    WXFMKMapZoomLevelTwelve,         //3.026493    2.059937
    WXFMKMapZoomLevelThirteen,       //6.030974    4.119873
    WXFMKMapZoomLevelFourteen,       //11.958328    8.239747
    WXFMKMapZoomLevelFifteen,        //23.553707    16.479494
    WXFMKMapZoomLevelSixteen,        //45.888102    32.958987
    WXFMKMapZoomLevelSeventeen       //74.502995    55.546876 全国地图
}WXFMKMapZoomLevel;

@protocol WXFDragMapViewDelegate <NSObject>

@optional
//开始拖拽
- (void)startDragmapView:(WXFDragMapView*)mapView;

//结束拖拽
- (void)endDragmapView:(WXFDragMapView*)mapView;

//开始双指手势
- (void)startPinchmapView:(WXFDragMapView*)mapView;

//结束双指手势
- (void)endPinchmapView:(WXFDragMapView*)mapView;

//开始双击
- (void)startDoubleTapmapView:(WXFDragMapView*)mapView;

//结束双击
- (void)endDoubleTapmapView:(WXFDragMapView*)mapView;

//开始定位
- (void)startRequestUserLocation:(WXFDragMapView*)mapView;

//停止用户定位
- (void)endRequestUserLocation:(WXFDragMapView*)mapView
                  userLocation:(CLLocation*)userLocation
                         error:(NSError*)error;


@end


@interface WXFDragMapView : UIView

@property (nonatomic, weak) id<WXFDragMapViewDelegate>delegate;

@property (nonatomic, strong, readonly) MKMapView* mapView;

//自定义的地图手势是否可用
//默认为YES
@property (nonatomic, assign) BOOL customMapGestureEnable;


@end
