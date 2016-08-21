//
//  AppDelegate.h
//  GitIgnore
//
//  Created by Eleven Chen on 16/8/19.
//  Copyright © 2016年 Eleven. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic) NSString* folderPath;

- (void) addGitignoreFile:(NSPasteboard *)pboard
            userData:(NSString *)userData error:(NSString **)error;

@end

