//
//  GithubApiManager.m
//  GitIgnore
//
//  Created by Eleven Chen on 16/8/20.
//  Copyright © 2016年 Eleven. All rights reserved.
//

#import "GithubApiManager.h"

@interface GithubApiManager()

@end

NSString* API_GET_TYPES = @"https://api.github.com/repos/github/gitignore/contents";
NSString* API_GET_CONTENT = @"https://raw.githubusercontent.com/github/gitignore/master/";
typedef void (^FetchCallbackString)(NSData* content);

@implementation GithubApiManager

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    static GithubApiManager* instance;
    dispatch_once(&onceToken, ^{
        instance = [[GithubApiManager alloc] init];
    });
    
    return instance;
}

-(void) fetchTypes:(FetchCallback) callback
{
    [self fetchURL:API_GET_TYPES callback:^(NSData *content) {
        // OK
        NSError* jsonError;
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingAllowFragments error:&jsonError];
        if (!jsonError) {
            if (callback != nil) {
                callback(jsonObject);
            }
        }
    }];
}

-(void) fetchContentWithType:(NSString*) type callback:(FetchCallback) callback
{
    NSString* url = [NSString stringWithFormat:@"%@%@", API_GET_CONTENT, type];
    [self fetchURL:url callback:^(NSData *content) {
        NSString* text = [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
        NSDictionary *dict = @{@"content": text};
        if (callback) {
            callback(dict);
        }
    }];
}

- (void) fetchURL:(NSString* ) url callback:(FetchCallbackString)callback
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            return ;
        }
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200) {
            if (callback) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(data);
                });
                
            }
        } else {
            NSLog(@"error status code: %ld", httpResp.statusCode);
        }
    }];
    [task resume];
}

@end
