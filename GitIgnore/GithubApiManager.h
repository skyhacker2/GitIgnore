//
//  GithubApiManager.h
//  GitIgnore
//
//  Created by Eleven Chen on 16/8/20.
//  Copyright © 2016年 Eleven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FetchCallback)(NSDictionary* dict);
@interface GithubApiManager : NSObject

+ (instancetype) sharedInstance;

-(void) fetchTypes:(FetchCallback) callback;

-(void) fetchContentWithType:(NSString*) type callback:(FetchCallback) callback;

@end
