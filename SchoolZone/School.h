//
//  School.h
//  SchoolZone
//
//  Created by Shawn on 28/6/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface School : NSObject

@property (nonatomic, copy) NSString *title;
//@property (nonatomic) NSUInteger type;
@property (nonatomic,readonly) NSString *phone;
@property (nonatomic,readonly) NSString *email;
@property (nonatomic,readonly) NSString *fax;
@property (nonatomic,readonly) NSString *principal;
@property (nonatomic,readonly) NSString *street;
@property (nonatomic,readonly) NSString *suburb;
@property (nonatomic,readonly) NSString *city;
@property (nonatomic,readonly) NSString *schoolNumberStr;

@property (nonatomic,readonly) NSArray *schoolGeoJsonArray;



- (instancetype)initWithDictionary:(NSDictionary *)schoolDictionary;

+ (NSDictionary *)allSchools;
+ (School *)schoolForIdString:(NSString *)idString;
+ (NSDictionary *)allSchoolsCoordinates;
@end
