//
//  School.m
//  SchoolZone
//
//  Created by Shawn on 28/6/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import "School.h"
#import "RNDecryptor.h"

@interface School()
@property (nonatomic, copy) NSDictionary *geo_json_pt;  //copy not effective performance , cause copy only do retain here.
@property (nonatomic, copy) NSArray *json_detail;
//@property (nonatomic, copy) NSDictionary *geo_json;

@end

@implementation School

- (instancetype)initWithDictionary:(NSDictionary *)schoolDictionary
{
    if (self = [super init]) {
        self.title = [schoolDictionary objectForKey:@"title"];
        self.geo_json_pt = [schoolDictionary objectForKey:@"geo_json_pt"];
        self.json_detail = [schoolDictionary objectForKey:@"json_detail"];
        [self _exactInfo];
        [self _exactSchoolGeoJsonArray:schoolDictionary];
    }
    return self;
}

- (NSString *)_infoFromKey:(NSString *)key
{
    //NSArray *infoArray =
    for (int i = 0; i < [self.json_detail count]; i++) {
        NSArray *infoArray = self.json_detail[i];
        if ([infoArray[0] isEqualToString:key]){
            return infoArray[1];
        }
    }
    return nil;
}

- (void)_exactSchoolGeoJsonArray:(NSDictionary *)schoolDictionary
{
    //_schoolGeoJsonDicionary = [schoolDictionary objectForKey:@"geo_json"];
    NSDictionary *dic = schoolDictionary[@"geo_json"];
    if (dic && [dic isKindOfClass:[NSDictionary class]] ) {
        NSArray *array = dic[@"coordinates"];
        _schoolGeoJsonArray = [[[array lastObject] lastObject]   copy];
    }else{
        _schoolGeoJsonArray = nil;
    }

}

- (void)_exactInfo
{
    //NSLog(@"dic %@", self.json_detail);
    _phone = [[self _infoFromKey:@"Phone"] copy];
    _email = [[self _infoFromKey:@"Email"] copy];
    _fax = [[self _infoFromKey:@"Fax"] copy];
    _principal = [[self _infoFromKey:@"Principal"] copy];
    _street = [[self _infoFromKey:@"Suburb"] copy];
    _suburb = [[self _infoFromKey:@"Email"] copy];
    _city = [[self _infoFromKey:@"City"] copy];
    _schoolNumberStr = [[self _infoFromKey:@"School Number"] copy];
}

+ (NSDictionary *)allSchools
{
    NSDictionary *result = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"school" ofType:@"data"];
    //NSLog(@"path:%@",path);
    NSError *error;
    NSData *encryptedData = [NSData dataWithContentsOfFile:path];
    NSString *aPassword = @"aQrCfkkjcwyCzP9dVdM4YV7AWAB73QVppUu3r83ZCHgE6PBF";
    NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                        withPassword:aPassword
                                               error:&error];
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:decryptedData options:0 error:&error]; 
    NSArray *schoolJsonArray = [parsedObject objectForKey:@"records"];
    for (int i = 0; i < [schoolJsonArray count]; i++) {
        School *school = [[self alloc]initWithDictionary:[schoolJsonArray objectAtIndex:i]];

        [result setValue:school forKey:school.schoolNumberStr];
    }

    return result;
}


+ (School *)schoolForIdString:(NSString *)idString
{
    //Fixme: e
    return [[School alloc] init];
}

+ (NSDictionary *)allSchoolsCoordinates{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"allSchoolsCoordinates" ofType:@"plist"];
    return  [NSDictionary dictionaryWithContentsOfFile:path];
}


/*  //this is the one that wrting , need to run once to prepare file allSchoolsCoordinates.plist
+ (NSDictionary *)allSchoolsCoordinates
{
    NSMutableDictionary     *result = [NSMutableDictionary dictionary];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"geo_all" ofType:@"json"];
    //NSLog(@"path:%@",path);
    NSError *error;
    NSData *content = [NSData dataWithContentsOfFile:path];
    //NSLog(@"%@",content);
    
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:content options:0 error:&error]; //count// records
    
    NSArray *schoolJsonArray = [parsedObject objectForKey:@"records"];
    for (int i = 0; i < [schoolJsonArray count]; i++) {
        NSDictionary *schoolDictionary = [schoolJsonArray objectAtIndex:i];

        NSDictionary *getJsonPtDic = [schoolDictionary objectForKey:@"geo_json_pt"];
        if ([getJsonPtDic isKindOfClass:[NSDictionary class]]) {
            NSArray *value = [getJsonPtDic objectForKey:@"coordinates"];
            NSString *key = [schoolDictionary objectForKey:@"id"];
            //NSDictionary *dic = [NSDictionary dictionaryWithObject:value forKey:key];
            //NSLog(@"%@ %d", dic, i);
            [result setObject:value forKey:key];
        }else{
            NSLog(@"%d, %@",i ,[schoolDictionary objectForKey:@"id"]  );
            //id, 701,2751 has no coodinates
            
        }
     
    }
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"ge" ofType:@"json"];
    NSString *dir  = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *writePath = [dir stringByAppendingPathComponent:@"allSchoolsCoordinates.plist"];
    NSLog(@"path %@",writePath);
    [result writeToFile:writePath atomically:YES];
    
    
    return result;
}
*/
- (NSString *)description
{
    return [NSString stringWithFormat:@"School:%@ %@ %@ %@ %@", self.schoolNumberStr, self.title, self.phone, self.principal, [self.geo_json_pt objectForKey:@"coordinates"]];
}
@end
