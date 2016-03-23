//
//  WXFDragMapView.m
//  WXFMapDemo
//
//  Created by yongche_w on 16/3/23.
//  Copyright © 2016年 yongche. All rights reserved.
//

#import "WXFDragMapView.h"

@interface WXFDragMapView() <MKMapViewDelegate>

@property (nonatomic, strong, readwrite) MKMapView* mapView;

//地图放大的等级
@property (nonatomic, assign) CGFloat mapZoomLevel;

//捏合手势
@property (nonatomic, strong) UIPinchGestureRecognizer* pinchGesture;

//捏合手势 begin的scale
@property (nonatomic, assign) CGFloat pinchGestureScale;

//双击手势
@property (nonatomic, strong) UITapGestureRecognizer* doubleTapGesture;

//拖拽手势
@property (nonatomic, strong) UIPanGestureRecognizer* panGesture;

//双击、推拽手势begin时候的点
@property (nonatomic, assign) CGPoint panGesturePoint;


@end

@implementation WXFDragMapView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        
        
        self.mapView = [[MKMapView alloc] initWithFrame:self.bounds] ;
        self.mapView.delegate = self;
        [self addSubview:self.mapView];
        self.customMapGestureEnable = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.mapView.frame = self.bounds;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(self.customMapGestureEnable){
        return self;
    }
    return [super hitTest:point withEvent:event];
}


- (void)setCustomMapGestureEnable:(BOOL)customMapGestureEnable
{
    _customMapGestureEnable = customMapGestureEnable;
    if(_customMapGestureEnable){
        [self addGestureRecognizerToSelf];
    }else{
        [self removeGestureRecognizerFromSelf];
    }
}

- (void)addGestureRecognizerToSelf
{
    [self removeGestureRecognizerFromSelf];
    
    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                    action:@selector(doubleTapGesturePress:)];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleTapGesture];
    
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(panGesturePress:)];
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:self.panGesture];
    
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(pinchGesturePress:)];
    [self addGestureRecognizer:self.pinchGesture];
    
}



- (void)removeGestureRecognizerFromSelf
{
    [self removeGestureRecognizer:self.pinchGesture];
    [self removeGestureRecognizer:self.doubleTapGesture];
    [self removeGestureRecognizer:self.panGesture];
}

- (void)pinchGesturePress:(UIPinchGestureRecognizer*)pinchGestureRecognizer
{
    if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan){
        self.pinchGestureScale = pinchGestureRecognizer.scale;
    }else if(pinchGestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CGFloat maxZoomLevel = [self changeMapZoomLevelToFloat:WXFMKMapZoomLevelSeventeen];
        CGFloat minZoomLevel = [self changeMapZoomLevelToFloat:WXFMKMapZoomLevelOne];
        
        
        self.mapZoomLevel += -pinchGestureRecognizer.velocity * 0.1 * self.mapZoomLevel;
        if(self.mapZoomLevel < minZoomLevel){
            self.mapZoomLevel = minZoomLevel;
        }else if(self.mapZoomLevel > maxZoomLevel){
            self.mapZoomLevel = maxZoomLevel;
        }
        [self setRegion:[self currentCenterCoordinate2D] zoomLevel:self.mapZoomLevel animated:NO];
        
        self.pinchGestureScale = pinchGestureRecognizer.scale;
        
    }else if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded){
        
    }
}

- (void)doubleTapGesturePress:(UITapGestureRecognizer*)tapGestureRecognizer
{
    
    
    WXFMKMapZoomLevel zoomLevel = [self changeFloatToMapZoomLevel:self.mapZoomLevel];
    
    if(zoomLevel > WXFMKMapZoomLevelOne){
        self.mapZoomLevel = [self changeMapZoomLevelToFloat:(zoomLevel - 1)];
        
        [self setRegion:[self currentCenterCoordinate2D] zoomLevel:self.mapZoomLevel animated:YES];
        
    }else if(zoomLevel == WXFMKMapZoomLevelOne){
        self.mapZoomLevel = [self changeMapZoomLevelToFloat:zoomLevel];
        [self setRegion:[self currentCenterCoordinate2D] zoomLevel:self.mapZoomLevel animated:YES];
    }
    
    
}

- (void)panGesturePress:(UIPanGestureRecognizer*)panGestureRecognizer
{
    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan){
        
        self.panGesturePoint = [panGestureRecognizer locationInView:self];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(startDragmapView:)]){
            [self.delegate startDragmapView:self];
        }
        
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CLLocationCoordinate2D centerCoorDinate = self.mapView.centerCoordinate;
        
        CGPoint point = [panGestureRecognizer locationInView:self];
        
        CLLocationCoordinate2D panGesturePointCoordinate2D = [self.mapView convertPoint:self.panGesturePoint toCoordinateFromView:self];
        
        CLLocationCoordinate2D currentPointCoordinate2D = [self.mapView convertPoint:point toCoordinateFromView:self];
        
        centerCoorDinate.latitude += -(currentPointCoordinate2D.latitude - panGesturePointCoordinate2D.latitude);
        centerCoorDinate.longitude += -(currentPointCoordinate2D.longitude - panGesturePointCoordinate2D.longitude);
        
        if (CLLocationCoordinate2DIsValid(centerCoorDinate)){
            
            [self.mapView setCenterCoordinate:centerCoorDinate animated:NO];
            self.panGesturePoint = point;
        }
        
        
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded){
        
        CLLocationCoordinate2D centerCoorDinate = self.mapView.centerCoordinate;
        
        CGPoint point = [panGestureRecognizer velocityInView:self];
        
        if(fabs(point.x ) > 10 && fabs(point.y ) > 10){
            
            CGPoint newPoint = CGPointMake(self.panGesturePoint.x + point.x * 0.5, self.panGesturePoint.y + point.y * 0.5);
            CLLocationCoordinate2D panGesturePointCoordinate2D = [self.mapView convertPoint:self.panGesturePoint toCoordinateFromView:self];
            
            CLLocationCoordinate2D currentPointCoordinate2D = [self.mapView convertPoint:newPoint toCoordinateFromView:self];
            
            centerCoorDinate.latitude += -(currentPointCoordinate2D.latitude - panGesturePointCoordinate2D.latitude);
            centerCoorDinate.longitude += -(currentPointCoordinate2D.longitude - panGesturePointCoordinate2D.longitude);
            
            if (CLLocationCoordinate2DIsValid(centerCoorDinate)){
                [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.mapView setCenterCoordinate:centerCoorDinate animated:NO];
                } completion:^(BOOL finished) {
                    if(self.delegate && [self.delegate respondsToSelector:@selector(endDragmapView:)]){
                        [self.delegate endDragmapView:self];
                    }
                }];
            }else{
                if(self.delegate && [self.delegate respondsToSelector:@selector(endDragmapView:)]){
                    [self.delegate endDragmapView:self];
                }
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(endDragmapView:)]){
                [self.delegate endDragmapView:self];
            }
        }
    }else if(panGestureRecognizer.state == UIGestureRecognizerStateCancelled || panGestureRecognizer.state == UIGestureRecognizerStateFailed){
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(endDragmapView:)]){
            [self.delegate endDragmapView:self];
        }
        
    }
}




- (CGFloat)changeMapZoomLevelToFloat:(WXFMKMapZoomLevel)zoomLevel
{
    CGFloat tempZoomLevel = 0.001484;
    switch (zoomLevel) {
        case WXFMKMapZoomLevelOne:{
            tempZoomLevel = 0.001484;
        }
            break;
        case WXFMKMapZoomLevelTwo:{
            tempZoomLevel = 0.002968;
        }
            break;
        case WXFMKMapZoomLevelThree:{
            tempZoomLevel = 0.005936;
        }
            break;
        case WXFMKMapZoomLevelFour:{
            tempZoomLevel = 0.011872;
        }
            break;
        case WXFMKMapZoomLevelFive:{
            tempZoomLevel = 0.023743;
        }
            break;
        case WXFMKMapZoomLevelSix:{
            tempZoomLevel = 0.047484;
        }
            break;
        case WXFMKMapZoomLevelSeven:{
            tempZoomLevel = 0.094961;
        }
            break;
        case WXFMKMapZoomLevelEight:{
            tempZoomLevel = 0.189895;
        }
            break;
        case WXFMKMapZoomLevelNine:{
            tempZoomLevel = 0.379681;
        }
            break;
        case WXFMKMapZoomLevelTen:{
            tempZoomLevel = 0.758927;
        }
            break;
        case WXFMKMapZoomLevelEleven:{
            tempZoomLevel = 1.516251;
        }
            break;
        case WXFMKMapZoomLevelTwelve:{
            tempZoomLevel = 3.026493;
        }
            break;
        case WXFMKMapZoomLevelThirteen:{
            tempZoomLevel = 6.030974;
        }
            break;
        case WXFMKMapZoomLevelFourteen:{
            tempZoomLevel = 11.958328;
        }
            break;
        case WXFMKMapZoomLevelFifteen:{
            tempZoomLevel = 23.553707;
        }
            break;
        case WXFMKMapZoomLevelSixteen:{
            tempZoomLevel = 45.888102;
        }
            break;
        case WXFMKMapZoomLevelSeventeen:{
            tempZoomLevel = 74.502995;
        }
            break;
            
        default:
            break;
    }
    return tempZoomLevel;
}

- (WXFMKMapZoomLevel)changeFloatToMapZoomLevel:(CGFloat)zoom
{
    WXFMKMapZoomLevel level = WXFMKMapZoomLevelOne;
    if(zoom > 74.502995){
        level = WXFMKMapZoomLevelSeventeen;
    }else if(zoom > 45.888102){
        level = WXFMKMapZoomLevelSixteen;
    }else if(zoom > 23.553707){
        level = WXFMKMapZoomLevelFifteen;
    }else if(zoom > 11.958328){
        level = WXFMKMapZoomLevelFourteen;
    }else if(zoom > 6.030974){
        level = WXFMKMapZoomLevelThirteen;
    }else if(zoom > 3.026493){
        level = WXFMKMapZoomLevelTwelve;
    }else if(zoom > 1.516251){
        level = WXFMKMapZoomLevelEleven;
    }else if(zoom > 0.758927){
        level = WXFMKMapZoomLevelTen;
    }else if(zoom > 0.379681){
        level = WXFMKMapZoomLevelNine;
    }else if(zoom > 0.189895){
        level = WXFMKMapZoomLevelEight;
    }else if(zoom > 0.094961){
        level = WXFMKMapZoomLevelSeven;
    }else if(zoom > 0.047484){
        level = WXFMKMapZoomLevelSix;
    }else if(zoom > 0.023743){
        level = WXFMKMapZoomLevelFive;
    }else if(zoom > 0.011872){
        level = WXFMKMapZoomLevelFour;
    }else if(zoom > 0.005936){
        level = WXFMKMapZoomLevelThree;
    }else if(zoom >0.002968){
        level = WXFMKMapZoomLevelTwo;
    }else if(zoom > 0.001484){
        level = WXFMKMapZoomLevelOne;
    }
    return level;
}

- (CLLocationCoordinate2D)currentCenterCoordinate2D
{
    
    CLLocationCoordinate2D center = [self.mapView convertPoint:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2) toCoordinateFromView:self];
    return center;
    return self.mapView.centerCoordinate;
}

- (void)setRegion:(CLLocationCoordinate2D)coords  zoomLevel:(float)zoomLevel animated:(BOOL)animated
{
    MKCoordinateSpan span = MKCoordinateSpanMake(zoomLevel, zoomLevel);
    MKCoordinateRegion region = MKCoordinateRegionMake(coords, span);
    [self.mapView setRegion:region animated:animated];
}
@end
