//
//  ClusterView.h
//  SchoolZone
//
//  Created by Shawn on 4/7/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface ClusterView : MKAnnotationView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier ;

@property (nonatomic) int number;

@end
