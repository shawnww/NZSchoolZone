//
//  MyCustomAnnotation.h
//  SchoolZone
//
//  Created by Shawn on 28/6/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MyCustomAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *schoolNumberStr;

//@property (nonatomic, copy) NSString *subtitle;

@end
