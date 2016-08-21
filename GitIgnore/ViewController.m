//
//  ViewController.m
//  GitIgnore
//
//  Created by Eleven Chen on 16/8/19.
//  Copyright © 2016年 Eleven. All rights reserved.
//

#import "ViewController.h"
#import "GithubApiManager.h"
#import "AppDelegate.h"

@interface ViewController() <NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>
@property (strong, nonatomic) GithubApiManager* githubApiManger;
@property (weak, nonatomic) IBOutlet NSTableView* tableView;
@property (weak, nonatomic) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSProgressIndicator *saveIndicator;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSTextField* filterField;

@property (strong, nonatomic) NSArray* types;
@property (strong, nonatomic) NSArray* arrangedTypes;
@property (strong, nonatomic) NSMutableDictionary* checkedDict;
@property (strong, nonatomic) AppDelegate* appDelegate;
@end

@implementation ViewController

- (AppDelegate*) appDelegate
{
    if (!_appDelegate) {
        _appDelegate = [NSApp delegate];
    }
    return _appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    _githubApiManger = [GithubApiManager sharedInstance];
    _checkedDict = [[NSMutableDictionary alloc] init];
    _scrollView.hidden = YES;
    _indicator.hidden = NO;
    _saveIndicator.hidden = YES;
    [_indicator startAnimation:nil];
    _filterField.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [_githubApiManger fetchTypes:^(NSDictionary *dict) {
        NSArray* array = (NSArray*) dict;
        weakSelf.arrangedTypes = [array copy];
        weakSelf.types = array;
        for (NSDictionary* type in array) {
            _checkedDict[type[@"name"]] = @(NO);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            weakSelf.scrollView.hidden = NO;
            weakSelf.indicator.hidden = YES;
            [weakSelf.indicator stopAnimation:nil];
        });
        
    }];

}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.arrangedTypes count];
}

-(NSView*) tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary* type = self.arrangedTypes[row];
    if ([tableColumn.identifier isEqualToString:@"MainCell"]) {
        NSTableCellView* cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        NSButton* button = [cell viewWithTag:0];
        button.title = type[@"name"];
        if ([self.checkedDict[type[@"name"]] boolValue]) {
            button.state = NSOffState;
        } else {
            button.state = NSOffState;
        }
        [button setAction:@selector(onCheckButtonChanged:)];

        return cell;
    }
    
    return nil;
}

- (IBAction)onCheckButtonChanged:(NSButton*)sender
{
    NSInteger row = [self.tableView rowForView:sender.superview];
    NSDictionary* type = self.arrangedTypes[row];
    self.checkedDict[type[@"name"]] = @(sender.state == NSOnState? YES : NO);
}

- (IBAction)onSave:(id)sender
{
    NSMutableArray* selectedTypes = [[NSMutableArray alloc] init];
    [self.checkedDict enumerateKeysAndObjectsUsingBlock:^(NSString*  _Nonnull key, NSNumber*  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj boolValue]) {
            [selectedTypes addObject:key];
        }
    }];
    if (selectedTypes.count == 0) {
        return;
    }
    
    self.saveButton.enabled = NO;
    self.saveIndicator.hidden = NO;
    [self.saveIndicator startAnimation:nil];

    if (self.appDelegate.folderPath) {
        NSString* filePath = [NSString stringWithFormat:@"%@/.gitignore", self.appDelegate.folderPath];
        NSFileManager* defaultManager = [NSFileManager defaultManager];
        if (![defaultManager fileExistsAtPath:filePath]) {
            [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
        }
        NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        
        [self writeToFile:fileHandle withTypes:selectedTypes];
    } else {
        NSOpenPanel* openPanel = [NSOpenPanel openPanel];
        openPanel.canChooseDirectories = YES;
        openPanel.canChooseFiles = NO;
        openPanel.allowsMultipleSelection = NO;
        
        __weak typeof (self) weakSelf = self;
        [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK) {
                NSString* path = [[[openPanel URLs] firstObject] path];
                if ([path hasSuffix:@"/"]) {
                    path = [path substringWithRange:NSMakeRange(0, path.length-1)];
                }

                weakSelf.appDelegate.folderPath = path;
                NSString* filePath = [NSString stringWithFormat:@"%@/.gitignore", self.appDelegate.folderPath];

                NSFileManager* defaultManager = [NSFileManager defaultManager];
                if (![defaultManager fileExistsAtPath:filePath]) {
                    [defaultManager createFileAtPath:filePath contents:nil attributes:nil];
                }
                NSFileHandle* fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
                
                [weakSelf writeToFile:fileHandle withTypes:selectedTypes];
            } else {
                weakSelf.saveButton.enabled = YES;
                weakSelf.saveIndicator.hidden = YES;
            }
        }];

    }
}


- (void) writeToFile:(NSFileHandle*) fileHandle withTypes:(NSMutableArray*) types
{
    if (types.count == 0) {
        [fileHandle synchronizeFile];
        [fileHandle closeFile];
        [self onWriteFinished];
        NSLog(@"write finished!");
    } else {
        NSString* type = [types firstObject];
        [types removeObjectAtIndex:0];
        __weak typeof (self) weakSelf = self;
        [[GithubApiManager sharedInstance] fetchContentWithType:type callback:^(NSDictionary *dict) {
            NSString* content = dict[@"content"];
            NSData* data = [content dataUsingEncoding:NSUTF8StringEncoding];
            [fileHandle writeData:data];
            
            [weakSelf writeToFile:fileHandle withTypes:types];
            
        }];

    }
}

- (void) onWriteFinished
{
    self.saveIndicator.hidden = YES;
    self.saveButton.enabled = YES;
    NSAlert* alert = [[NSAlert alloc] init];
    alert.messageText = @".gitignore Create Finished";
    
    [alert addButtonWithTitle:@"Open .gitignore"];
    [alert addButtonWithTitle:@"OK"];
    __weak typeof (self) weakSelf = self;
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString* path = [NSString stringWithFormat:@"%@/.gitignore", weakSelf.appDelegate.folderPath];
            [[NSWorkspace sharedWorkspace] openFile:path];
        }
    }];
}

- (void) controlTextDidChange:(NSNotification *)obj
{
    NSLog(@"%@", self.filterField.stringValue);
    NSString* string = [self.filterField.stringValue lowercaseString];
    if (string.length == 0) {
        self.arrangedTypes = [self.types copy];
        [self.tableView reloadData];
        return;
    }
    NSMutableArray* filterArray = [[NSMutableArray alloc] init];
    for (NSDictionary* dict in self.types) {
        NSString* name = [dict[@"name"] lowercaseString];
        if ([name hasPrefix:string]) {
            NSLog(@"name %@", name);
            [filterArray addObject:dict];
        }
    }
    self.arrangedTypes = [filterArray copy];
    [self.tableView reloadData];
}


@end
