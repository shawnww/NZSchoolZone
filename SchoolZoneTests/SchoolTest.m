//
//  SchoolTest.m
//  SchoolZone
//
//  Created by Shawn on 5/7/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "School.h"

@interface SchoolTest : XCTestCase
@property (nonatomic, strong)  NSDictionary* allSchools;
@end

@implementation SchoolTest

- (void)setUp {
    [super setUp];
    
    
    self.allSchools = [School allSchools];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testCount{
    XCTAssert([self.allSchools allKeys].count == 2548, @"2548 schools");
    //XCTAssert([self.allSchools[@"count"] integerValue] == [self.allSchools[@"records"] count], @"number not right");
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}



@end
