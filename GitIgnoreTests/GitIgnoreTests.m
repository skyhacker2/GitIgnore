//
//  GitIgnoreTests.m
//  GitIgnoreTests
//
//  Created by Eleven Chen on 16/8/19.
//  Copyright © 2016年 Eleven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GithubApiManager.h"

@interface GitIgnoreTests : XCTestCase

@end

@implementation GitIgnoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGetTypes {
    XCTestExpectation *expectation =
    [self expectationWithDescription:@"testGetTypes"];
    
    [[GithubApiManager sharedInstance] fetchTypes:^(NSDictionary *dict) {
        NSLog(@"%@", dict);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGetContent {
    XCTestExpectation *expectation =
    [self expectationWithDescription:@"testGetContent"];
    [[GithubApiManager sharedInstance] fetchContentWithType:@"Unity.gitignore" callback:^(NSDictionary *dict) {
        NSLog(@"%@", dict);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
